import { tableStyles, utilizationBarVariants, dialogStyles } from './tableStyles.css';

function formatNextRepave(nextRepave: string) {
  if (!nextRepave) return 'N/A';
  const nextRepave2 = nextRepave.substring(0, 10);
  return nextRepave2;
}

interface LinkA1 {
  onClick: (event: React.MouseEvent<HTMLFormElement>) => void;
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
    const sortedPools: Pool[] = [...pools].sort((a: Pool, b: Pool) =>
      desc ? b.avgCpu - a.avgCpu : a.avgCpu - b.avgCpu
    );
    setPools(sortedPools);
    setSortKey('avgCpu');
    setSortDesc(desc);
  };

  const sortByAvailability = () => {
    const desc = sortKey === 'availability' ? !sortDesc : true;
    const sortedPools: Pool[] = [...pools].sort((a: Pool, b: Pool) => {
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
    const sortedPools: Pool[] = [...pools].sort((a: Pool, b: Pool) => {
      const aValue = a.instances[0]?.capacity.maxSlice ?? 0;
      const bValue = b.instances[0]?.capacity.maxSlice ?? 0;
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
    return Math.round(((total - available) / total) * 100);
  };

  const handleContinue = () => {
    setConfirmedPools(selectedPools);
    setShowDialog(false);
  };

  const handleConfirm = () => {
    setConfirmedPools(selectedPools);
    setShowDialog(false);
  };

  const handleDeleteConfirmedPool = (pool: Pool) => {
    setConfirmedPools((prev) => prev.filter((p) => p !== pool));
  };

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;

  return (
    <div className={tableStyles.container}>
      <h1>Latest Pool Information</h1>
      <h2>Select Pools to migrate To</h2>
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
            <tr key={pool.pool} className={tableStyles.tableRow}>
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
                    style={{ width: `${pool.avgCpu}%` }}
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
                        getAvailabilityPercentage(pool.instances[0].capacity.available, pool.instances[0].capacity.total) > 70
                          ? 'high'
                          : getAvailabilityPercentage(pool.instances[0].capacity.available, pool.instances[0].capacity.total) > 50
                          ? 'medium'
                          : 'low'
                      ]
                    }
                    style={{
                      width: `${getAvailabilityPercentage(
                        pool.instances[0].capacity.available,
                        pool.instances[0].capacity.total
                      )}%`,
                    }}
                  />
                  <span className={tableStyles.utilizationText}>
                    {getAvailabilityPercentage(
                      pool.instances[0].capacity.available,
                      pool.instances[0].capacity.total
                    )}
                    %
                  </span>
                </div>
              </td>
              <td className={tableStyles.td}>
                {pool.instances[0]?.nextRepave ? formatNextRepave(pool.instances[0].nextRepave) : 'N/A'}
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
      <button onClick={() => setShowDialog(true)} className={tableStyles.showSelectedButton}>
        Show Selected Pools
      </button>
      {showDialog && (
        <div className={dialogStyles.overlay}>
          <div className={dialogStyles.dialog}>
            <h2>Selected Pools</h2>
            <ul className={tableStyles.selectedPools}>
              {selectedPools.map((pool) => (
                <li key={pool.pool}>{pool.pool}</li>
              ))}
            </ul>
            <button onClick={handleConfirm} className={dialogStyles.continueButton}>
              Yes
            </button>
            <button onClick={() => setShowDialog(false)} className={dialogStyles.closeButton}>
              No
            </button>
          </div>
        </div>
      )}
      {confirmedPools.length > 0 && (
        <div>
          <h2>Confirmed Pools</h2>
          <ul className={tableStyles.confirmedPools}>
            {confirmedPools.map((pool) => (
              <li key={pool.pool}>
                {pool.pool}
                <button
                  onClick={() => handleDeleteConfirmedPool(pool)}
                  className={tableStyles.deleteButton}
                >
                  Delete
                </button>
              </li>
            ))}
          </ul>
          <button
            className={dialogStyles.migrateButton}
            disabled={confirmedPools.length === 0}
          >
            Migrate
          </button>
        </div>
      )}
    </div>
  );
};

export default PoolTable;



  
import { style } from 'typestyle';

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
      '&:hover': {
        backgroundColor: '#45a049',
      },
    },
  }),
  selectedPools: style({
    marginTop: '20px',
    padding: '10px 20px',
    backgroundColor: '#2a2a2a',
    color: '#ffffff',
    borderRadius: '8px',
  }),
  confirmedPools: style({
    marginTop: '20px',
    padding: '10px 20px',
    backgroundColor: '#2a2a2a',
    color: '#ffffff',
    borderRadius: '8px',
  }),
  deleteButton: style({
    marginLeft: '10px',
    padding: '5px 10px',
    backgroundColor: '#f44336',
    color: 'white',
    border: 'none',
    borderRadius: '5px',
    cursor: 'pointer',
    fontSize: '14px',
      '&:hover': {
        backgroundColor: '#d32f2f',
      },
    },
  }),
  tableRow: style({
    transition: 'background-color 0.3s',
      '&:hover': {
        backgroundColor: '#f5f5f5', // Or any other color that suits your design
      },
    },
  }),
};

export const utilizationBarVariants = styleVariants({
  low: { backgroundColor: '#4CAF50' },
  medium: { backgroundColor: '#ffc107' },
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
      '&:hover': {
        backgroundColor: '#45a049',
      },
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
      '&:hover': {
        backgroundColor: '#d32f2f',
      },
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
      '&:hover': {
        backgroundColor: '#1976D2',
      },
    },
  }),
};
