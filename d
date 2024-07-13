const SortButton: React.FC<{ column: 'avgCpu' | 'availability' | 'maxSlice'; sortKey: 'avgCpu' | 'availability' | 'maxSlice' | null; sortDesc: boolean; onSort: (column: 'avgCpu' | 'availability' | 'maxSlice') => void }> = ({ column, sortKey, sortDesc, onSort }) => {
  const columnName =
    column === 'avgCpu' ? 'Avg CPU' :
    column === 'availability' ? 'Availability' :
    'Max Slice';

  return (
    <button onClick={() => onSort(column)} className={tableStyles.sortButton}>
      {columnName} {sortKey === column ? (sortDesc ? '▼' : '▲') : '⇅'}
    </button>
  );
};

const PoolTable: React.FC = () => {
  const [pools, setPools] = useState<Pool[]>([]);
  const [selectedPools, setSelectedPools] = useState<Pool[]>([]);
  const [sortKey, setSortKey] = useState<'avgCpu' | 'availability' | 'maxSlice' | null>(null);
  const [sortDesc, setSortDesc] = useState(true);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    setIsLoading(true);
    getFilteredPoolInfo()
      .then(response => {
        setPools(response.data);
        setIsLoading(false);
      })
      .catch(err => {
        console.error(err);
        setError('Failed to fetch pool data');
        setIsLoading(false);
      });
  }, []);

  const sortByAvgCpu = () => {
    const desc = sortKey === 'avgCpu' ? !sortDesc : true;
    const sortedPools = [...pools].sort((a, b) => desc ? b.avgCpu - a.avgCpu : a.avgCpu - b.avgCpu);
    setPools(sortedPools);
    setSortKey('avgCpu');
    setSortDesc(desc);
  };

  const sortByAvailability = () => {
    const desc = sortKey === 'availability' ? !sortDesc : true;
    const sortedPools = [...pools].sort((a, b) => {
      const aValue = a.instances[0]?.capacity.available ?? 0;
      const bValue = b.instances[0]?.capacity.available ?? 0;
      return desc ? bValue - aValue : aValue - bValue;
    });
    setPools(sortedPools);
    setSortKey('availability');
    setSortDesc(desc);
  };

  const sortByMaxSlice = () => {
    const desc = sortKey === 'maxSlice' ? !sortDesc : true;
    const sortedPools = [...pools].sort((a, b) => {
      const aValue = a.instances[0]?.capacity.maxSlice ?? 0;
      const bValue = b.instances[0]?.capacity.maxSlice ?? 0;
      return desc ? bValue - aValue : aValue - bValue;
    });
    setPools(sortedPools);
    setSortKey('maxSlice');
    setSortDesc(desc);
  };

  const togglePoolSelection = (pool: Pool) => {
    setSelectedPools(prev => 
      prev.includes(pool) ? prev.filter(p => p !== pool) : [...prev, pool]
    );
  };

  const getAvailabilityPercentage = (available: number, total: number): number => {
    if (total === 0) return 0;
    return Math.round(((total - available) / total) * 100);
  };

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;

  return (
    <div className={tableStyles.container}>
      <table className={tableStyles.table}>
        <thead>
          <tr>
            <th className={tableStyles.th}>Region</th>
            <th className={tableStyles.th}>Pool</th>
            <th className={tableStyles.th}><button onClick={sortByAvgCpu} className={tableStyles.sortButton}>Avg CPU {sortKey === 'avgCpu' ? (sortDesc ? '▼' : '▲') : '⇅'}</button></th>
            <th className={tableStyles.th}><button onClick={sortByMaxSlice} className={tableStyles.sortButton}>Max Slice {sortKey === 'maxSlice' ? (sortDesc ? '▼' : '▲') : '⇅'}</button></th>
            <th className={tableStyles.th}><button onClick={sortByAvailability} className={tableStyles.sortButton}>Availability {sortKey === 'availability' ? (sortDesc ? '▼' : '▲') : '⇅'}</button></th>
            <th className={tableStyles.th}>Next Repave</th>
            <th className={tableStyles.th}>Select</th>
          </tr>
        </thead>
        <tbody>
          {pools.map(pool => (
            <tr key={pool.pool}>
              <td className={tableStyles.td}>{pool.region}</td>
              <td className={tableStyles.td}>{pool.pool}</td>
              <td className={tableStyles.td}>
                <div className={tableStyles.utilization}>
                  <div
                    className={
                      tableStyles.utilizationBar +
                      ' ' +
                      utilizationBarVariants[
                        pool.avgCpu > 70 ? 'high' : pool.avgCpu > 50 ? 'medium' : 'low'
                      ]
                    }
                    style={{
                      width: `${pool.avgCpu}%`,
                    }}
                  />
                  <span className={tableStyles.utilizationText}>{roundCpu(pool.avgCpu)}</span>
                </div>
              </td>
              <td className={tableStyles.td}>{formatSlice(pool.instances[0].capacity.maxSlice)}</td>
              <td className={tableStyles.td}>
                <div className={tableStyles.utilization}>
                  <div
                    className={
                      tableStyles.utilizationBar +
                      ' ' +
                      utilizationBarVariants[
                        getAvailabilityPercentage(pool.instances[0].capacity.available, pool.instances[0].capacity.total) > 70 ? 'high' : 
                        getAvailabilityPercentage(pool.instances[0].capacity.available, pool.instances[0].capacity.total) > 50 ? 'medium' : 
                        'low'
                      ]
                    }
                    style={{
                      width: `${getAvailabilityPercentage(pool.instances[0].capacity.available, pool.instances[0].capacity.total)}%`,
                    }}
                  />
                  <span className={tableStyles.utilizationText}>
                    {getAvailabilityPercentage(pool.instances[0].capacity.available, pool.instances[0].capacity.total)}%
                  </span>
                </div>
              </td>
              <td className={tableStyles.td}>{pool.instances[0]?.nextRepave2 ? formatNextRepave(pool.instances[0].nextRepave2) : 'N/A'}</td>
              <td className={tableStyles.td}>
                <input
                  type="checkbox"
                  checked={selectedPools.includes(pool)}
                  onChange={() => togglePoolSelection(pool)}
                />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      <div className={tableStyles.selectedPools}>
        <h2>Selected Pools</h2>
        <ul>
          {selectedPools.map(pool => (
            <li key={pool.pool}>{pool.pool}</li>
          ))}
        </ul>
      </div>
    </div>
  );
};

export default PoolTable;
