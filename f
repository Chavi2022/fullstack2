const PoolTable: React.FC = () => {
  const [pools, setPools] = useState<Pool[]>([]);
  const [selectedPools, setSelectedPools] = useState<Pool[]>([]);
  const [sortKey, setSortKey] = useState<'avgCpu' | 'availability' | 'maxSlice' | null>(null);
  const [sortDesc, setSortDesc] = useState(true);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showDialog, setShowDialog] = useState(false);
  const [showMigrate, setShowMigrate] = useState(false);
  const [migrationData, setMigrationData] = useState<string[]>([]);

  useEffect(() => {
    setIsLoading(true);
    getFilteredPoolInfo()
      .then(response => {
        setPools(response.data);
        setIsLoading(false);
      })
      .catch(err => {
        console.error('Failed to fetch pool data', err);
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
      const aValue = a.instances[0].capacity.available ?? 0;
      const bValue = b.instances[0].capacity.available ?? 0;
      return desc ? bValue - aValue : aValue - bValue;
    });
    setPools(sortedPools);
    setSortKey('availability');
    setSortDesc(desc);
  };

  const sortByMaxSlice = () => {
    const desc = sortKey === 'maxSlice' ? !sortDesc : true;
    const sortedPools = [...pools].sort((a, b) => {
      const aValue = a.instances[0].capacity.maxSlice ?? 0;
      const bValue = b.instances[0].capacity.maxSlice ?? 0;
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

  const handleContinue = () => {
    setShowMigrate(true);
    handleMigrate();
  };

  const handleMigrate = () => {
    const selectedPoolNames = selectedPools.map(pool => pool.poolName);
    setMigrationData(selectedPoolNames);
  };

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>{error}</div>;

  return (
    <div className={tableStyles.container}>
      <h1>Latest Pool Information</h1>
      <h2>Select Pools to migrate To:</h2>
      <table className={tableStyles.table}>
        <thead>
          <tr>
            <th className={tableStyles.th}>Region</th>
            <th className={tableStyles.th}>Pool</th>
            <th className={tableStyles.th}>
              <button className={tableStyles.sortButton} onClick={sortByAvgCpu}>
                Avg CPU {sortKey === 'avgCpu' ? (sortDesc ? '▼' : '▲') : ''}
              </button>
            </th>
            <th className={tableStyles.th}>
              <button className={tableStyles.sortButton} onClick={sortByMaxSlice}>
                Max Slice {sortKey === 'maxSlice' ? (sortDesc ? '▼' : '▲') : ''}
              </button>
            </th>
            <th className={tableStyles.th}>Availability</th>
            <th className={tableStyles.th}>Next Repave</th>
            <th className={tableStyles.th}>Select</th>
          </tr>
        </thead>
        <tbody>
          {pools.map(pool => (
            <tr key={pool.poolName}>
              <td className={tableStyles.td}>{pool.region}</td>
              <td className={tableStyles.td}>{pool.poolName}</td>
              <td className={tableStyles.td}>{pool.avgCpu}</td>
              <td className={tableStyles.td}>{pool.instances[0].capacity.maxSlice}</td>
              <td className={tableStyles.td}>
                <div
                  className={`${tableStyles.utilization} ${
                    pool.instances[0].capacity.available > 70 ? 'high' : 'low'
                  }`}
                  style={{ width: `${pool.avgCpu}%` }}
                >
                  {pool.avgCpu}
                </div>
                <span className={tableStyles.utilizationText}>
                  {pool.instances[0].capacity.available > 70 ? 'high' : 'low'}
                </span>
              </td>
              <td className={tableStyles.td}>
                {pool.instances[0].nextRepave ? pool.instances[0].nextRepave : 'N/A'}
              </td>
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
      <button onClick={() => setShowDialog(true)} className={tableStyles.showSelectedButton} disabled={selectedPools.length === 0}>
        Show Selected Pools
      </button>
      {showDialog && (
        <div className={dialogStyles.overlay}>
          <div className={dialogStyles.dialog}>
            <h2>Selected Pools</h2>
            <ul className={tableStyles.selectedPools}>
              {selectedPools.map((pool, index) => (
                <li key={index}>{pool.poolName}</li>
              ))}
            </ul>
            <button onClick={handleContinue} className={dialogStyles.continueButton}>
              Yes
            </button>
            <button onClick={() => setShowDialog(false)} className={dialogStyles.closeButton}>
              No
            </button>
          </div>
        </div>
      )}
      {showMigrate && (
        <ServicesAndAppsPage poolNames={migrationData} />
      )}
    </div>
  );
};

export default PoolTable;
