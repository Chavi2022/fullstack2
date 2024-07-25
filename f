import React, { createContext, useContext, useState } from 'react';

const SelectedPoolsContext = createContext();

export const SelectedPoolsProvider = ({ children }) => {
    const [selectedPoolNames, setSelectedPoolNames] = useState([]);
    const [apiLink, setApiLink] = useState('');

    return (
        <SelectedPoolsContext.Provider value={{ selectedPoolNames, setSelectedPoolNames, apiLink, setApiLink }}>
            {children}
        </SelectedPoolsContext.Provider>
    );
};

export const useSelectedPools = () => useContext(SelectedPoolsContext);




const PoolTable = () => {
    const [pools, setPools] = useState([]);
    const [selectedPools, setSelectedPools] = useState([]);
    const { setSelectedPoolNames, setApiLink } = useSelectedPools();
    const [sortKey, setSortKey] = useState('');
    const [sortDesc, setSortDesc] = useState(true);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState(null);
    const [showDialog, setShowDialog] = useState(false);
    const [showMigrate, setShowMigrate] = useState(false);
    const [migrationData, setMigrationData] = useState([]);

    const fetchApiLink = async (selectedPools) => {
        try {
            const response = await axios.post('/api/getApiLink', { pools: selectedPools });
            setApiLink(response.data.apiLink);
        } catch (error) {
            console.error('Failed to fetch apiLink', error);
        }
    };

    const handleMigrate = async () => {
        const poolNames = selectedPools.map(pool => pool.pool);
        setSelectedPoolNames(poolNames);
        console.log('Selected Pools for Migration:', poolNames);
        await fetchApiLink(selectedPools);

        setShowMigrate(true);
        setMigrationData(poolNames);
    };

    const handleSort = (key) => {
        const desc = sortKey === key ? !sortDesc : true;
        const sortedPools = [...pools].sort((a, b) => {
            let aValue, bValue;

            switch (key) {
                case 'availability':
                    aValue = (a.instances[0]?.capacity.available ?? 0) / (a.instances[0]?.capacity.total ?? 1) * 100;
                    bValue = (b.instances[0]?.capacity.available ?? 0) / (b.instances[0]?.capacity.total ?? 1) * 100;
                    break;
                case 'avgCpu':
                    aValue = a.avgCpu;
                    bValue = b.avgCpu;
                    break;
                case 'maxSlice':
                    aValue = a.instances[0]?.capacity.maxSlice ?? 0;
                    bValue = b.instances[0]?.capacity.maxSlice ?? 0;
                    break;
                case 'region':
                    aValue = a.region;
                    bValue = b.region;
                    break;
                case 'pool':
                    aValue = a.pool;
                    bValue = b.pool;
                    break;
                case 'nextRepave':
                    aValue = a.instances[0]?.nextRepave ?? '';
                    bValue = b.instances[0]?.nextRepave ?? '';
                    break;
                default:
                    return 0;
            }

            if (typeof aValue === 'string' && typeof bValue === 'string') {
                return desc ? bValue.localeCompare(aValue) : aValue.localeCompare(bValue);
            }
            return desc ? bValue - aValue : aValue - bValue;
        });

        setPools(sortedPools);
        setSortKey(key);
        setSortDesc(desc);
    };

    useEffect(() => {
        setIsLoading(true);
        axios.get('/api/getPools')
            .then(response => {
                setPools(response.data);
                setIsLoading(false);
            })
            .catch(error => {
                console.error('Failed to fetch pool data', error);
                setError('Failed to fetch pool data');
                setIsLoading(false);
            });
    }, []);

    const togglePoolSelection = (pool) => {
        setSelectedPools(prev => prev.includes(pool) ? prev.filter(p => p !== pool) : [...prev, pool]);
    };

    const handleContinue = () => {
        setShowDialog(false);
        setShowMigrate(true);
    };

    return (
        <div className={tableStyles.container}>
            <h1>Strategic Migration Pools</h1>
            <h6 className="green">Choose Pools to Migrate To</h6>
            <table className={tableStyles.table}>
                <thead>
                    <tr>
                        <th className={tableStyles.th}>
                            <button onClick={() => handleSort('region')} className={tableStyles.sortButton}>
                                Region {sortKey === 'region' ? (sortDesc ? '▼' : '▲') : ''}
                            </button>
                        </th>
                        <th className={tableStyles.th}>
                            <button onClick={() => handleSort('pool')} className={tableStyles.sortButton}>
                                Pool {sortKey === 'pool' ? (sortDesc ? '▼' : '▲') : ''}
                            </button>
                        </th>
                        <th className={tableStyles.th}>
                            <button onClick={() => handleSort('nextRepave')} className={tableStyles.sortButton}>
                                Next Repave {sortKey === 'nextRepave' ? (sortDesc ? '▼' : '▲') : ''}
                            </button>
                        </th>
                        <th className={tableStyles.th}>
                            <button onClick={() => handleSort('avgCpu')} className={tableStyles.sortButton}>
                                Avg CPU {sortKey === 'avgCpu' ? (sortDesc ? '▼' : '▲') : ''}
                            </button>
                        </th>
                        <th className={tableStyles.th}>
                            <button onClick={() => handleSort('availability')} className={tableStyles.sortButton}>
                                Availability {sortKey === 'availability' ? (sortDesc ? '▼' : '▲') : ''}
                            </button>
                        </th>
                        <th className={tableStyles.th}>
                            <button onClick={() => handleSort('maxSlice')} className={tableStyles.sortButton}>
                                Max Slice {sortKey === 'maxSlice' ? (sortDesc ? '▼' : '▲') : ''}
                            </button>
                        </th>
                        <th className={tableStyles.th}>Select</th>
                    </tr>
                </thead>
                <tbody>
                    {pools.map(pool => (
                        <tr key={pool.pool}>
                            <td className={tableStyles.td}>{pool.region}</td>
                            <td className={tableStyles.td}>{pool.pool}</td>
                            <td className={tableStyles.td}>{pool.instances[0]?.nextRepave ? formatNextRepave(pool.instances[0].nextRepave) : 'N/A'}</td>
                            <td className={tableStyles.td}>
                                <div className={tableStyles.utilization}>
                                    <div
                                        className={tableStyles.utilizationBar + ' ' +
                                            utilizationBarVariants[getAvailabilityPercentage(pool.instances[0].capacity.available, pool.instances[0].capacity.total) > 70 ? 'high' :
                                                getAvailabilityPercentage(pool.instances[0].capacity.available, pool.instances[0].capacity.total) > 50 ? 'medium' : 'low']}
                                        style={{ width: `${getAvailabilityPercentage(pool.instances[0].capacity.available, pool.instances[0].capacity.total)}%` }}>
                                    </div>
                                    <span className={tableStyles.utilizationText}>
                                        {getAvailabilityPercentage(pool.instances[0].capacity.available, pool.instances[0].capacity.total)}%
                                    </span>
                                </div>
                            </td>
                            <td className={tableStyles.td}>{roundCpu(pool.avgCpu)}</td>
                            <td className={tableStyles.td}>{formatSlice(pool.instances[0].capacity.maxSlice)}</td>
                            <td className={tableStyles.td}>
                                <input type="checkbox" checked={selectedPools.includes(pool)} onChange={() => togglePoolSelection(pool)} />
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>
            <button onClick={() => setShowDialog(true)} className={tableStyles.showSelectedButton} disabled={selectedPools.length === 0}>
                Pools Chosen To Migrate
            </button>
            {showDialog && (
                <div className={dialogStyles.overlay}>
                    <div className={dialogStyles.dialog}>
                        <h2>Selected Pools</h2>
                        <ul className={tableStyles.selectedPools}>
                            {selectedPools.map((pool, index) => (
                                <li key={index}>{pool.pool}</li>
                            ))}
                        </ul>
                        <button onClick={handleContinue} className={dialogStyles.continueButton}>Yes</button>
                        <button onClick={() => setShowDialog(false)} className={dialogStyles.closeButton}>No</button>
                    </div>
                </div>
            )}
            {showMigrate && (
                <div className={dialogStyles.migrateSection}>
                    <h2>Selected Pools for Migration</h2>
                    <ul className={tableStyles.selectedPools}>
                        {selectedPools.map((pool, index) => (
                            <li key={index}>{pool.pool}</li>
                        ))}
                    </ul>
                    <button onClick={handleMigrate} className={dialogStyles.migrateButton}>
                        Migrate App To Pool(s)
                    </button>
                </div>
            )}
            {showMigrate && <ServicesAndAppsPage poolNames={migrationData} />}
        </div>
    );
};

const formatNextRepave = (nextRepave) => {
    if (!nextRepave) return 'N/A';
    return nextRepave.substring(0, 10);
};

const roundCpu = (avgCpu) => Math.round(avgCpu);

const formatSlice = (maxSlice) => maxSlice;

const getAvailabilityPercentage = (available, total) => {
    if (total === 0) return 0;
    return Math.round((available / total) * 100);
};

export default PoolTable;



import React, { useContext } from 'react';
import { SelectedPoolsContext } from './SelectedPoolsContext';

const ServicesAndAppsPage = ({ poolNames }) => {
    const { apiLink } = useContext(SelectedPoolsContext);

    return (
        <div className="background">
            <h1>Creating Services In New Pools</h1>
            <h2>Installing your services...</h2>
            <ul>
                {poolNames.map((poolName, index) => (
                    <li key={index}>Service Name Created in "{poolName}"....in progress</li>
                ))}
            </ul>
            <h2>Creating Your Apps In New Pools</h2>
            <p>Creating Your Apps...</p>
            <ul>
                {poolNames.map((poolName, index) => (
                    <li key={index}>App name Created in "{poolName}"....in progress</li>
                ))}
            </ul>
        </div>
    );
};

export default ServicesAndAppsPage;
