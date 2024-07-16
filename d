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
  low: { backgroundColor: '#1b5e20' },
  medium: { backgroundColor: '#f9a825' },
  high: { backgroundColor: '#b71c1c' },
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
  deleteButton: style({
    padding: '6px 12px',
    backgroundColor: '#d32f2f',
    color: 'white',
    border: 'none',
    borderRadius: '4px',
    cursor: 'pointer',
    fontSize: '14px',
    marginLeft: '10px',
    ':hover': {
      backgroundColor: '#b71c1c',
    },
  }),
  confirmedPoolsContainer: style({
    marginTop: '20px',
    padding: '20px',
    backgroundColor: '#2a2a2a',
    borderRadius: '8px',
  }),
  confirmedPoolItem: style({
    padding: '10px',
    border: '1px solid #3a3a3a',
    marginBottom: '10px',
    borderRadius: '5px',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
  }),
  selectedPools: style({
    listStyleType: 'none',
    padding: 0,
    margin: 0,
  }),
  migrationOptions: style({
    listStyleType: 'none',
    padding: 0,
    margin: 0,
  }),
  confirmedPools: style({
    listStyleType: 'none',
    padding: 0,
    margin: 0,
  }),
};


import React, { useState, useEffect } from 'react';
import { tableStyles, dialogStyles, utilizationBarVariants } from './styles';

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
      {/* Component JSX */}
    </div>
  );
};

export default PoolTable;
