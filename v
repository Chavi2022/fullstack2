import React, { useState } from "react";
import { getFilteredPoolInfo } from "./services/FilteredPoolService";
import { Pool } from "./Interfaces/Pool";
import { computeUtilization, formatRepaveDate, roundCpu } from "./lib/utils";
import styles from "./App.module.scss";

const App: React.FC = () => {
  const [pools, setPools] = useState<Pool[]>([]);
  const [error, setError] = useState<string | null>(null);

  const handleRetrieveFilteredPools = async () => {
    try {
      const data = await getFilteredPoolInfo();
      setPools(data);
    } catch (error) {
      setError("Error fetching pool data");
    }
  };

  return (
    <div className={styles.addressTable}>
      <h2>Press the button below to get available pools</h2>
      <div className="mds-row">
        <div className="mds-col-12">
          <button
            id="retrievePoolInfo"
            className="btn btn-primary"
            onClick={handleRetrieveFilteredPools}
            data-testid="clickHandleRetrieveFilteredPools"
          >
            Retrieve Filtered Pools
          </button>
        </div>
      </div>
      {error && <div>{error}</div>}
      {pools.map((pool, index) => (
        <div key={index} className="pool">
          <h2>{pool.region} - {pool.pool}</h2>
          <p>Data Center Type: {pool.dataCenterType}</p>
          <p>Average CPU: {roundCpu(pool.avgCpu)}</p>
          {pool.instances.map((instance, idx) => (
            <div key={idx} className="instance">
              <h3>Instance Environment: {instance.env}</h3>
              <p>Available: {instance.capacity.available}</p>
              <p>Max Slice: {instance.capacity.maxSlice}</p>
              <p>Used: {instance.capacity.used}</p>
              <p>Total: {instance.capacity.total}</p>
              <p>Utilization: {computeUtilization(instance.capacity.available, instance.capacity.total)}</p>
              <p>Next Repave Date: {formatRepaveDate(instance.nextRepave || "")}</p>
            </div>
          ))}
        </div>
      ))}
    </div>
  );
};

export default App;
