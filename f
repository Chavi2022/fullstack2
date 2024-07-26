import React, { useEffect, useState } from 'react';
import { useApiContext } from '../ApiContext';
import axios from 'axios';

interface MigrationComponentProps {
    poolNames: string[];
}

interface Service {
    newPools: string;
    serviceName: string;
}

const ServicesAndAppsPage: React.FC<MigrationComponentProps> = ({ poolNames }) => {
    const { apiLinks } = useApiContext();
    const [services, setServices] = useState<Service[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const fetchServices = async () => {
            try {
                const response = await axios.post('http://localhost:8080/createServices', {
                    newPools: poolNames,
                    serviceName: 'YourServiceName',
                    user: 'yourUsername',
                    password: 'yourPassword'
                });
                setServices(response.data);
            } catch (error) {
                if (axios.isAxiosError(error)) {
                    setError(error.message);
                } else {
                    setError('An unexpected error occurred');
                }
            } finally {
                setLoading(false);
            }
        };

        fetchServices();
    }, [poolNames]);

    if (loading) {
        return <div>Loading... in progress</div>;
    }

    if (error) {
        return <div>FAILURE: {error}</div>;
    }

    return (
        <div className="background">
            <h1>Creating Services In New Pools</h1>
            <p>Installing your services...</p>
            {poolNames.map((poolName: string, index: number) => (
                <p key={index}>
                    Service Name created in "{poolName}" using API: {apiLinks[poolName]}... in progress
                </p>
            ))}
            <h2>Creating Your Apps In New Pools</h2>
            <p>Creating Your Apps...</p>
            {poolNames.map((poolName: string, index: number) => (
                <p key={index}>
                    "App name" created in "{poolName}" using API: {apiLinks[poolName]}... in progress
                </p>
            ))}
        </div>
    );
};

export default ServicesAndAppsPage;
