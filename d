import { style, styleVariants } from '@vanilla-extract/css';

export const tableStyles = {
  container: style({
    width: '100%',
    maxWidth: '1600px',
    margin: '2rem auto',
    backgroundColor: '#1e1e1e',
    borderRadius: '8px',
    overflow: 'hidden',
    fontFamily: 'Arial, sans-serif',
    textAlign: 'center',
    borderColor: 'grey',
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
    textAlign: 'center',
  }),
  utilization: style({
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#3a3a3a',
    borderRadius: '4px',
    overflow: 'hidden',
    height: '16px',
    width: '100%',
    position: 'relative',
  }),
  utilizationBar: style({
    height: '100%',
    borderRadius: '4px',
    position: 'absolute',
    left: 0,
  }),
  utilizationText: style({
    position: 'relative',
    zIndex: 1,
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
    color: '#ffffff',
    borderRadius: '8px',
    listStyleType: 'none',
    paddingLeft: 0,
  }),
  sortButton: style({
    background: 'none',
    border: 'none',
    cursor: 'pointer',
    fontWeight: 'bold',
    color: '#ffffff',
    padding: '0',
    display: 'flex',
    alignItems: 'center',
    ':hover': {
      color: '#4CAF50',
    },
    '::after': {
      content: '""',
      marginLeft: '4px',
    },
  }),
  disabledButton: style({
    opacity: 0.5,
    cursor: 'not-allowed',
  }),
};

export const utilizationBarVariants = styleVariants({
  low: { backgroundColor: '#4caf50' },
  medium: { backgroundColor: '#ffeb3b' },
  high: { backgroundColor: '#ff5722' },
});

export const dialogStyles = {
  overlay: style({
    position: 'fixed',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 1000,
  }),
  dialog: style({
    backgroundColor: '#2a2a2a',
    padding: '20px',
    borderRadius: '8px',
    maxWidth: '500px',
    width: '100%',
    boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
    color: '#ffffff',
  }),
  continueButton: style({
    marginRight: '10px',
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
  closeButton: style({
    padding: '10px 20px',
    backgroundColor: '#f44336',
    color: 'white',
    border: 'none',
    borderRadius: '5px',
    cursor: 'pointer',
    fontSize: '16px',
    ':hover': {
      backgroundColor: '#d32f2f',
    },
    marginLeft: '10px',
  }),
  confirmButton: style({
    padding: '10px 20px',
    backgroundColor: 'green',
    color: 'white',
    border: 'none',
    borderRadius: '5px',
    cursor: 'pointer',
    fontSize: '16px',
    ':hover': {
      backgroundColor: '#6c819f',
    },
    marginLeft: '10px',
  }),
  migrateButton: style({
    marginTop: '20px',
    padding: '10px 20px',
    backgroundColor: '#2196F3',
    color: 'white',
    border: 'none',
    borderRadius: '5px',
    cursor: 'pointer',
    fontSize: '16px',
    ':hover': {
      backgroundColor: '#1976D2',
    },
  }),
  disabledButton: style({
    opacity: 0.5,
    cursor: 'not-allowed',
  }),
  migrationOption: style({
    cursor: 'pointer',
    padding: '8px',
    ':hover': {
      backgroundColor: '#333333',
    },
  }),
  migrationOptions: style({
    listStyleType: 'none',
    padding: 0,
  }),
  confirmedPools: style({
    listStyleType: 'none',
    padding: 0,
  }),
  confirmedPoolItem: style({
    padding: '10px',
    border: '1px solid #9a9ac6',
    marginBottom: '10px',
    borderRadius: '5px',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  }),
};






  
function formatNextRepave(nextRepave: string): string {
  if (!nextRepave) return 'N/A';
  const nextRepave2 = nextRepave.substring(0, 10);
  return nextRepave2;
}

const PoolTable: React.FC = (): Element => {
  const [pools, setPools] = useState<Pool[]>([]);
  const [selectedPools, setSelectedPools] = useState<Pool[]>([]);
  const [sortKey, setSortKey] = useState<'avgCpu' | 'availability' | 'maxSlice' | null>(null);
  const [sortDesc, setSortDesc] = useState(true);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showDialog, setShowDialog] = useState(false);
  const [confirmedPools, setConfirmedPools] = useState<Pool[]>([]);

  useEffect(() => {
    setIsLoading(true);
    getFilteredPoolInfo()
      .then((response: { data: Pool[] }) => {
        setPools(response.data);
        setIsLoading(false);
      })
      .catch((err) => {
        console.error(err);
        setError('Failed to fetch pool data');
        setIsLoading(false);
      });
  }, []);

  const sortByAvgCpu = () => {
    const desc = sortKey === 'avgCpu' ? !sortDesc : true;
    const sortedPools = [...pools].sort((a, b) => (desc ? b.avgCpu - a.avgCpu : a.avgCpu - b.avgCpu));
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
    setSelectedPools((prev) =>
      prev.includes(pool) ? prev.filter((p) => p !== pool) : [...prev, pool]
    );
  };

  const handleConfirm = () => {
    if (selectedPools.length > 0) {
      setShowDialog(true);
    }
  };

  const handleMigrate = (targetPool: Pool) => {
    console.log(`Migrating ${selectedPools.length} pools to ${targetPool.pool}`);
    setShowDialog(false);
    setSelectedPools([]);
    setConfirmedPools((prev) => [...prev, ...selectedPools]);
  };

  const getAvailabilityPercentage = (available: number, total: number): number => {
    if (total === 0) return 0;
    return Math.round(((total - available) / total) * 100);
  };

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;

  return (
    <div className={tableStyles.container}>
      <h2>Select pools to migrate</h2>
      <table className={tableStyles.table}>
        <thead>
          <tr>
            <th className={tableStyles.th}>Region</th>
            <th className={tableStyles.th}>Pool</th>
            <th className={tableStyles.th}>
              <button onClick={sortByAvgCpu} className={tableStyles.sortButton}>
                Avg CPU {sortKey === 'avgCpu' ? (sortDesc ? '▼' : '▲') : ''}
              </button>
            </th>
            <th className={tableStyles.th}>
              <button onClick={sortByMaxSlice} className={tableStyles.sortButton}>
                Max Slice {sortKey === 'maxSlice' ? (sortDesc ? '▼' : '▲') : ''}
              </button>
            </th>
            <th className={tableStyles.th}>
              <button onClick={sortByAvailability} className={tableStyles.sortButton}>
                Availability {sortKey === 'availability' ? (sortDesc ? '▼' : '▲') : ''}
              </button>
            </th>
            <th className={tableStyles.th}>Next Repave</th>
            <th className={tableStyles.th}>Select</th>
          </tr>
        </thead>
        <tbody>
          {pools.map((pool: Pool) => (
            <tr key={pool.pool}>
              <td className={tableStyles.td}>{pool.region}</td>
              <td className={tableStyles.td}>{pool.pool}</td>
              <td className={tableStyles.td}>
                <div className={tableStyles.utilization}>
                  <div
                    className={tableStyles.utilizationBar}
                    style={{
                      width: `${pool.avgCpu}%`,
                      backgroundColor: utilizationBarVariants[
                        pool.avgCpu > 70 ? 'high' : pool.avgCpu > 50 ? 'medium' : 'low'
                      ],
                    }}
                  />
                  <span className={tableStyles.utilizationText}>{roundCpu(pool.avgCpu)}%</span>
                </div>
              </td>
              <td className={tableStyles.td}>
                <span className={tableStyles.utilizationText}>
                  {pool.instances[0]?.capacity.maxSlice ?? 0}
                </span>
              </td>
              <td className={tableStyles.td}>
                <div className={tableStyles.utilization}>
                  <div
                    className={tableStyles.utilizationBar}
                    style={{
                      width: `${getAvailabilityPercentage(
                        pool.instances[0]?.capacity.available ?? 0,
                        pool.instances[0]?.capacity.total ?? 0
                      )}%`,
                      backgroundColor: utilizationBarVariants[
                        getAvailabilityPercentage(
                          pool.instances[0]?.capacity.available ?? 0,
                          pool.instances[0]?.capacity.total ?? 0
                        ) > 70
                          ? 'high'
                          : getAvailabilityPercentage(
                              pool.instances[0]?.capacity.available ?? 0,
                              pool.instances[0]?.capacity.total ?? 0
                            ) > 50
                          ? 'medium'
                          : 'low'
                      ],
                    }}
                  />
                  <span className={tableStyles.utilizationText}>
                    {getAvailabilityPercentage(
                      pool.instances[0]?.capacity.available ?? 0,
                      pool.instances[0]?.capacity.total ?? 0
                    )}
                    %
                  </span>
                </div>
              </td>
              <td className={tableStyles.td}>
                {pool.instances[0]?.nextRepave
                  ? formatNextRepave(pool.instances[0].nextRepave)
                  : 'N/A'}
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
      <button
        onClick={handleConfirm}
        className={`${tableStyles.showSelectedButton} ${
          selectedPools.length === 0 ? tableStyles.disabledButton : ''
        }`}
        disabled={selectedPools.length === 0}
      >
        Confirm Selected Pools
      </button>
      {showDialog && (
        <div className={dialogStyles.overlay}>
          <div className={dialogStyles.dialog}>
            <h2>Select Migration Target{selectedPools.length > 1 ? 's' : ''}</h2>
            <ul className={dialogStyles.selectedPools}>
              {selectedPools.map((pool) => (
                <li key={pool.pool}>{pool.pool}</li>
              ))}
            </ul>
            <h3>Other Available Pools</h3>
            <ul className={dialogStyles.migrationOptions}>
              {pools
                .filter((pool) => !selectedPools.includes(pool))
                .map((pool) => (
                  <li key={pool.pool} onClick={() => handleMigrate(pool)} className={dialogStyles.migrationOption}>
                    {pool.pool}
                  </li>
                ))}
            </ul>
            <button onClick={() => setShowDialog(false)} className={dialogStyles.confirmButton}>
              Confirm
            </button>
            <button onClick={() => setShowDialog(false)} className={dialogStyles.closeButton}>
              Cancel
            </button>
          </div>
        </div>
      )}
      {confirmedPools.length > 0 && (
        <div>
          <h3>Confirmed Pools for Migration</h3>
          <ul className={dialogStyles.confirmedPools}>
            {confirmedPools.map((pool) => (
              <li key={pool.pool} className={dialogStyles.confirmedPoolItem}>
                {pool.pool}
                <button onClick={() => handleMigrate(pool)} className={dialogStyles.migrateButton}>
                  Migrate
                </button>
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
};

export default PoolTable;
