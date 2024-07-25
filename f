import React, { createContext, useContext, useState, ReactNode } from 'react';

interface ApiContextProps {
    apiLinks: { [key: string]: string };
    setApiLinks: (links: { [key: string]: string }) => void;
}

const ApiContext = createContext<ApiContextProps | undefined>(undefined);

export const useApiContext = () => {
    const context = useContext(ApiContext);
    if (!context) {
        throw new Error('useApiContext must be used within an ApiProvider');
    }
    return context;
};

export const ApiProvider = ({ children }: { children: ReactNode }) => {





interface PoolTableProps {}

const formatNextRepave = (nextRepave?: string): string => {
    if (!nextRepave) return 'N/A';
    return nextRepave.substring(0, 10);
};

const PoolTable: React.FC<PoolTableProps> = () => {
    const { apiLinks, setApiLinks } = useApiContext();
    const [pools, setPools] = useState<Pool[]>([]);
    const [selectedPools, setSelectedPools] = useState<Pool[]>([]);
    const [sortKey, setSortKey] = useState<'avgCpu' | 'availability' | 'maxSlice' | 'region' | 'pool' | 'nextRepave'>('avgCpu');
    const [sortDesc, setSortDesc] = useState(true);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [showDialog, setShowDialog] = useState(false);
    const [showMigrate, setShowMigrate] = useState(false);
    const [migrationData, setMigrationData] = useState<string[]>([]);

    useEffect(() => {
        getFilteredPoolInfo()
            .then(response => {
                const data = response.data;
                setPools(data);

                // Set the API links
                const links = data.reduce((acc: { [key: string]: string }, pool: Pool) => {
                    acc[pool.pool] = pool.instances[0].api;
                    return acc;
                }, {});
                setApiLinks(links);
                setIsLoading(false);
            })
            .catch(err => {
                console.error('Failed to fetch pool data', err);
                setError('Failed to fetch pool data');
                setIsLoading(false);
            });
    }, [setApiLinks]);

    const handleSort = (key: 'avgCpu' | 'availability' | 'maxSlice' | 'region' | 'pool' | 'nextRepave') => {
        const desc = sortKey === key ? !sortDesc : true;
        const sortedPools = [...pools].sort((a, b) => {
            let aValue: any;
            let bValue: any;

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

    const handleMigrate = () => {
        selectedPools.forEach(pool => {
            const apiLink = apiLinks[pool.pool];
            console.log('API Link:', apiLink); // Use the API link as needed
            // Perform the migration using the apiLink
        });
    };

    const togglePoolSelection = (pool: Pool) => {
        setSelectedPools(prev =>
            prev.includes(pool) ? prev.filter(p => p !== pool) : [...prev, pool]
        );
    };

    if (isLoading) return <div>Loading...</div>;
    if (error) return <div>Error: {error}</div>;

    return (
        <div className={tableStyles.container}>
            <Entries />
            <h1>Strategic Migration Pools</h1>
            <h6>Choose Pools to Migrate To</h6>
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
                            <td className={tableStyles.td}>{formatNextRepave(pool.instances[0].nextRepave)}</td>
                            <td className={tableStyles.td}>{pool.avgCpu}</td>
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
                                            width: `${getAvailabilityPercentage(pool.instances[0].capacity.available, pool.instances[0].capacity.total)}%`,
                                        }}
                                    />
                                    <span className={tableStyles.utilizationText}>
                                        {getAvailabilityPercentage(pool.instances[0].capacity.available, pool.instances[0].capacity.total)}%
                                    </span>
                                </div>
                            </td>
                            <td className={tableStyles.td}>{pool.instances[0].capacity.maxSlice}</td>
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
            <button onClick={handleMigrate} className={dialogStyles.migrateButton}>
                Migrate App To Pool(s)
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
                        <button onClick={handleMigrate} className={dialogStyles.continueButton}>
                            Yes
                        </button>
                        <button onClick={() => setShowDialog(false)} className={dialogStyles.closeButton}>
                            No
                        </button>
                    </div>
                </div>
            )}
        </div>
    );

    function getAvailabilityPercentage(available: number, total: number): number {
        if (total === 0) return 0;
        return Math.round((available / total) * 100);
    }
};

export default PoolTable;
