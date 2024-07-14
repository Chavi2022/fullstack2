const PoolTable: React.FC = () => {
  const [pools, setPools] = useState<Pool[]>([]);
  const [selectedPools, setSelectedPools] = useState<Pool[]>([]);
  const [sortKey, setSortKey] = useState<'avgCpu' | 'available' | 'maxSlice' | null>(null);
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
    const sortedPools = [...pools].sort((a, b) => {
      return desc ? b.avgCpu - a.avgCpu : a.avgCpu - b.avgCpu;
    });
    setPools(sortedPools);
    setSortKey('avgCpu');
    setSortDesc(desc);
  };

  const sortByAvailable = () => {
    const desc = sortKey === 'available' ? !sortDesc : true;
    const sortedPools = [...pools].sort((a, b) => {
      const aInstance = a.instances[0];
      const bInstance = b.instances[0];
      
      if(!aInstance || !bInstance) return 0;
      
      const aPercentage = (aInstance.capacity.available / aInstance.capacity.total) * 100;
      const bPercentage = (bInstance.capacity.available / bInstance.capacity.total) * 100;
      
      if (aPercentage === bPercentage) return 0;
      if(desc){
        return bPercentage - aPercentage;
      } else {
        return aPercentage - bPercentage;
      }
    });
    setPools(sortedPools);
    setSortKey('available');
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

  const SortButton = ({ column }: { column: 'avgCpu' | 'available' | 'maxSlice' }) => {
    const sortFunction = 
      column === 'avgCpu' ? sortByAvgCpu :
      column === 'available' ? sortByAvailable :
      sortByMaxSlice;

    const columnName =
      column === 'avgCpu' ? 'Avg CPU' :
      column === 'available' ? 'Available' :
      'Max Slice';

    return (
      <button onClick={sortFunction} className={tableStyles.sortButton}>
        {columnName} {sortKey === column && (sortDesc ? '▼' : '▲')}
      </button>
    );
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
            <th className={tableStyles.th}>
              <SortButton column="avgCpu" />
            </th>
            <th className={tableStyles.th}>
              <SortButton column="maxSlice" />
            </th>
            <th className={tableStyles.th}>
              <SortButton column="available" />
            </th>
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
And here's the updated tableStyles.css:
javascriptCopyimport { style, styleVariants } from '@vanilla-extract/css';

export const tableStyles = {
  container: style({
    width: '100%',
    maxWidth: '1600px',
    margin: '2rem auto',
    backgroundColor: '#1e1e1e',
    borderRadius: '8px',
    overflow: 'hidden',
    fontFamily: 'Arial, sans-serif',
  }),
  table: style({
    width: '100%',
    borderCollapse: 'collapse',
  }),
  th: style({
    backgroundColor: '#2a2a2a',
    color: '#ffffff',
    padding: '12px 16px',
    textAlign: 'center',
    fontWeight: 'bold',
    fontSize: '14px',
  }),
  td: style({
    padding: '12px 16px',
    backgroundColor: '#252525',
    color: '#ffffff',
    fontSize: '14px',
  }),
  utilization: style({
    display: 'flex',
    alignItems: 'center',
  }),
  utilizationBar: style({
    height: '8px',
    borderRadius: '4px',
    marginRight: '8px',
    backgroundColor: '#4caf50',
    flexGrow: 1,
  }),
  utilizationText: style({
    marginLeft: '8px',
  }),
  showSelectedButton: style({
    marginTop: '20px',
    padding: '10px 20px',
    backgroundColor: '#4CAF50',
    color: 'white',
    border: 'none',
    borderRadius: '5px',
    cursor: 'pointer',
    fontSize: '16px',
    ':hover': {
      backgroundColor: '#45a049',
    },
  }),
  selectedPools: style({
    marginTop: '20px',
    padding: '10px 20px',
    backgroundColor: '#2a2a2a',
    borderRadius: '8px',
    color: '#ffffff',
  }),
  sortButton: style({
    background: 'none',
    border: 'none',
    cursor: 'pointer',
    fontWeight: 'bold',
    color: '#ffffff',
    padding: '0',
    display: 'inline-flex',
    alignItems: 'center',
    justifyContent: 'center',
    width: '100%',
    ':hover': {
      color: '#4CAF50',
    },
    '::after': {
      content: '"⇅"',
      marginLeft: '4px',
    },
  }),
};

export const utilizationBarVariants = styleVariants({
  low: { backgroundColor: '#4caf50' },
  medium: { backgroundColor: '#ffc107' },
  high: { backgroundColor: '#ff5722' }
});
