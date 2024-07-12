import React, { useState, useEffect } from 'react';
import { getFilteredPoolInfo } from '../../services/filteredPoolService'; // Adjust path as needed
import type { Pool } from '../../interfaces/Pool'; // Adjust path as needed
import { roundCpu, computeAvailability, formatSlice } from '../../utils/change'; // Adjust path as needed
import { tableStyles, getUtilizationBarStyle, dialogStyles } from './tableStyles.css'; // Adjust path as needed

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
                  <div className={tableStyles.utilizationBar} style={getUtilizationBarStyle(pool.avgCpu)} />
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
