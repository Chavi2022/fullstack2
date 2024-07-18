import { tableStyles, utilizationBarVariants, dialogStyles } from './tableStyles.css';

function formatNextRepave(nextRepave: string): string {
  if (!nextRepave) return 'N/A';
  return nextRepave.substring(0, 10);
}

interface LinkAll {
  onClick: (event: React.MouseEvent<HTMLFormElement>) => void;
}

const PoolTable: React.FC = () => {
  const [pools, setPools] = useState<Pool[]>([]);
  const [selectedPools, setSelectedPools] = useState<Pool[]>([]);
  const [sortKey, setSortKey] = useState<'avgCpu' | 'availability' | 'maxSlice' | null>(null);
  const [sortDesc, setSortDesc] = useState(true);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showDialog, setShowDialog] = useState(false);

  useEffect(() => {
    setIsLoading(true);
    getFilteredPoolInfo()
      .then((response) => {
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

  const getAvailabilityPercentage = (available: number, total: number): number => {
    if (total === 0) return 0;
    return Math.round((total - available) / total) * 100;
  };

  const handleContinue = () => {
    setShowDialog(false);
  };

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;

  return (
    <div className={tableStyles.container}>
      <h1>Latest Pool Information</h1>
      <h2>Select Pools to migrate To/ho</h2>
      <table className={tableStyles.table}>
        <thead>
          <tr>
            <th className={tableStyles.th}>Region</th>
            <th className={tableStyles.th}>Avg CPU</th>
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
            <th className={tableStyles.th}>Select</th>
            <th className={tableStyles.th}>Next Repave</th>
          </tr>
        </thead>
        <tbody>
          {pools.map((pool) => (
            <tr key={pool.pool} className={tableStyles.row}>
              <td className={tableStyles.td}>{pool.region}</td>
              <td className={tableStyles.td}>{roundCpu(pool.avgCpu)}</td>
              <td className={tableStyles.td}>{formatSlice(pool.instances[0].capacity.maxSlice)}</td>
              <td className={tableStyles.td}>{computeAvailability(pool.instances[0].capacity.available)}</td>
              <td className={tableStyles.td}>
                <input
                  type="checkbox"
                  checked={selectedPools.includes(pool)}
                  onChange={() => togglePoolSelection(pool)}
                />
              </td>
              <td className={tableStyles.td}>{formatNextRepave(pool.instances[0].nextRepave)}</td>
            </tr>
          ))}
        </tbody>
      </table>
      <button
        onClick={() => setShowDialog(true)}
        className={tableStyles.showSelectedButton}
        disabled={selectedPools.length === 0}
      >
        Show Selected Pools
      </button>

      {showDialog && (
        <div className={dialogStyles.overlay}>
          <div className={dialogStyles.dialog}>
            <h2>Selected Pools</h2>
            <ul>
              {selectedPools.map((pool) => (
                <li key={pool.pool}>{pool.pool}</li>
              ))}
            </ul>
            <button onClick={handleContinue} className={dialogStyles.continueButton}>
              Continue
            </button>
            <button onClick={() => setShowDialog(false)} className={dialogStyles.closeButton}>
              Close
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default PoolTable;



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
    position: 'relative',
    transition: 'background-color 0.3s, color 0.3s',
    ':hover': {
      backgroundColor: '#ffffff',
      color: '#212121',
    },
  }),
  utilization: style({
    display: 'flex',
    alignItems: 'center',
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
  }),
  utilizationText: style({
    marginLeft: '8px',
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
    ':disabled': {
      backgroundColor: '#cccccc',
      cursor: 'not-allowed',
    },
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
  listStyleNone: style({
    paddingLeft: '0', // Remove padding left to get rid of bullet point space
    listStyleType: 'none',
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
};

export const utilizationBarVariants = styleVariants({
  low: { backgroundColor: '#4CAF50' },
  medium: { backgroundColor: '#ffeb3b' },
  high: { backgroundColor: '#f57224' },
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
};
