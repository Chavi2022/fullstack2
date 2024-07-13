import { tableStyles, utilizationBarVariants, dialogStyles } from './tableStyles.css'; // Adjust path as needed

function formatNextRepave(dateString: string): string {
  const date = new Date(dateString);
  const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  const dayName = days[date.getDay()];
  const monthName = months[date.getMonth()];
  const dayOfMonth = date.getDate();
  return `${dayName}, ${monthName} ${dayOfMonth}`;
}

const PoolTable: React.FC = () => {
  const [pools, setPools] = useState<Pool[]>([]);
  const [selectedPools, setSelectedPools] = useState<string[]>([]);
  const [sortKey, setSortKey] = useState<'avgCpu' | 'availability' | 'maxSlice' | null>(null);
  const [sortDesc, setSortDesc] = useState(true);
  const [showDialog, setShowDialog] = useState(false);
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

  const togglePoolSelection = (poolName: string) => {
    setSelectedPools(prev => prev.includes(poolName) ? prev.filter(p => p !== poolName) : [...prev, poolName]);
  };

  const handleContinue = () => {
    console.log("Continuing with selected pools:", selectedPools);
    setShowDialog(false);
  };

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;

  const SortButton: React.FC<{ column: 'avgCpu' | 'availability' | 'maxSlice' }> = ({ column }) => {
    const sortFunction =
      column === 'avgCpu' ? sortByAvgCpu :
      column === 'availability' ? sortByAvailability :
      sortByMaxSlice;

    const columnName =
      column === 'avgCpu' ? 'Avg CPU' :
      column === 'availability' ? 'Availability' :
      'Max Slice';

    return (
      <button onClick={sortFunction} className={tableStyles.sortButton}>
        {columnName} {sortKey === column ? (sortDesc ? '▼' : '▲') : '⇅'}
      </button>
    );
  };

  return (
    <div className={tableStyles.container}>
      <table className={tableStyles.table}>
        <thead>
          <tr>
            <th className={tableStyles.th}>Pool</th>
            <th className={tableStyles.th}><SortButton column="avgCpu" /></th>
            <th className={tableStyles.th}><SortButton column="maxSlice" /></th>
            <th className={tableStyles.th}><SortButton column="availability" /></th>
            <th className={tableStyles.th}>Next Repave</th>
            <th className={tableStyles.th}>Select</th>
          </tr>
        </thead>
        <tbody>
          {pools.map(pool => (
            <tr key={pool.pool}>
              <td className={tableStyles.td}>{pool.pool}</td>
              <td className={tableStyles.td}>
                <div className={tableStyles.utilization}>
                  <div
                    className={tableStyles.utilizationBar}
                    style={{
                      ...utilizationBarVariants[
                        pool.avgCpu > 70 ? 'high' : pool.avgCpu > 50 ? 'medium' : 'low'
                      ],
                      width: `${pool.avgCpu}%`,
                    }}
                  />
                  <span className={tableStyles.utilizationText}>{roundCpu(pool.avgCpu)}</span>
                </div>
              </td>
              <td className={tableStyles.td}>{formatSlice(pool.instances[0].capacity.maxSlice)}</td>
              <td className={tableStyles.td}>{computeAvailability(pool.instances[0].capacity.available, pool.instances[0].capacity.total)}</td>
              <td className={tableStyles.td}>{pool.instances[0]?.nextRepave ? formatNextRepave(pool.instances[0].nextRepave) : 'N/A'}</td>
              <td className={tableStyles.td}>
                <input
                  type="checkbox"
                  checked={selectedPools.includes(pool.pool)}
                  onChange={() => togglePoolSelection(pool.pool)}
                />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      <button onClick={() => setShowDialog(true)} className={tableStyles.showSelectedButton}>
        Show Selected Pools
      </button>
      {showDialog && (
        <div className={dialogStyles.overlay}>
          <div className={dialogStyles.dialog}>
            <h2>Selected Pools</h2>
            <ul>
              {selectedPools.map(pool => (
                <li key={pool}>{pool}</li>
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
  }),
  table: style({
    width: '100%',
    borderCollapse: 'separate',
    borderSpacing: '0 1px',
  }),
  th: style({
    backgroundColor: '#2a2a2a',
    color: '#ffffff',
    padding: '12px 16px',
    textAlign: 'left',
    fontWeight: 'bold',
    fontSize: '14px',
  }),
  td: style({
    padding: '12px 16px',
    backgroundColor: '#252525',
    color: '#ffffff',
    fontSize: '14px',
  }),
  checkboxCell: style({
    display: 'flex',
    justifyContent: 'center',
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
      content: '"⇅"',
      marginLeft: '4px',
    },
  }),
  envTypeDev: style({
    display: 'inline-block',
    backgroundColor: '#9c27b0',
    color: 'white',
    padding: '2px 6px',
    borderRadius: '4px',
    fontSize: '12px',
  }),
  utilization: style({
    display: 'flex',
    alignItems: 'center',
  }),
  utilizationBar: style({
    height: '8px',
    borderRadius: '4px',
    marginRight: '8px',
  }),
  utilizationText: style({
    minWidth: '36px',
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
};

export const utilizationBarVariants = styleVariants({
  low: { backgroundColor: '#4caf50' },
  medium: { backgroundColor: '#ffc107' },
  high: { backgroundColor: '#ff5722' }
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
};
