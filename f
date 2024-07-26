import { style } from "@vanilla-extract/css";

export const container = style({
  width: "84%",
  background: "#212121",
  border: "solid 2px #313131",
  padding: "20px",
  margin: "50px auto",
  borderRadius: "10px",
  textAlign: "center",
  color: "#fff",
  boxShadow: "0 4px 8px rgba(0, 0, 0, 0.1)",
});

export const inputStyles = style({
  width: "60%",
  padding: "10px",
  margin: "10px 0",
  borderRadius: "5px",
  border: "1px solid #ccc",
  fontSize: "16px",
  color: "#212121",
  boxSizing: "border-box",
});

export const formStyles = style({
  display: "flex",
  flexDirection: "column",
  alignItems: "flex-start",
  gap: "10px",
});

export const formGroup = style({
  display: "flex",
  alignItems: "center",
  justifyContent: "space-between",
  width: "100%",
});

export const labelStyles = style({
  width: "30%",
  textAlign: "right",
  marginRight: "10px",
  fontSize: "16px",
  color: "#fff",
});

export const dropdown = style({
  width: "60%",
  padding: "10px",
  margin: "10px 0",
  borderRadius: "5px",
  border: "1px solid #ccc",
  fontSize: "16px",
  color: "#212121",
  boxSizing: "border-box",
});

export const dropdownDiv = style({
  width: "100%",
});

export const buttonStyles = style({
  width: "20%",
  padding: "10px 20px",
  border: "none",
  borderRadius: "5px",
  background: "#4CAF50",
  color: "#fff",
  cursor: "pointer",
  transition: "background 0.3s",
});

export const listStyles = style({
  marginLeft: "auto",
  marginRight: "auto",
  width: "30%",
  marginTop: "20px",
  textAlign: "center",
  padding: "10px",
  borderRadius: "5px",
  background: "#333",
  color: "#fff",
});

export const sectionTitle = style({
  fontSize: "1.5em",
  margin: "20px 0",
  textAlign: "center",
  color: "#4CAF50",
});

export const invisible = style({
  display: "none",
});

export const visible = style({
  display: "block",
});

export const loading = style({
  marginLeft: "43%",
});

export const aestric = style({
  color: "red",
});


import React, { useState, useEffect } from 'react';
import {
  container,
  buttonStyles,
  formStyles,
  inputStyles,
  dropdown,
  dropdownDiv,
  listStyles,
  sectionTitle,
  visible,
  invisible,
  loading,
  aestric,
  formGroup,
  labelStyles
} from './Entries.css';
import { getOldPools, getProjectList } from '../../services/BitBucketApiService';

function Entries(): JSX.Element {
  const [isVisible, setIsVisible] = useState(false);
  const [dropdownVisible, setDropdownVisible] = useState(false);
  const [appProjectKey, setAppProjectKey] = useState('');
  const [serviceProjectKey, setServiceProjectKey] = useState('');
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [appNames, setAppNames] = useState<string[]>([]);
  const [appName, setAppName] = useState('');
  const [time, setTime] = useState(500);
  const [oldPools, setOldPools] = useState<string[]>([]);

  const Alert = () => {
    setIsVisible(true);
    setIsLoading(true);

    getOldPools(appProjectKey, appName)
      .then((response: { data: OldPool[] }) => {
        setOldPools(response.data);
        setIsLoading(false);
      });
  };

  const populateDropdown = () => {
    getProjectList(appProjectKey)
      .then(response => {
        setIsLoading(false);
        setDropdownVisible(true);
        let appArray = response.data.values;

        const names: string[] = [];
        Object.values(appArray).forEach((value, index: number) => {
          names.push(value.name);
        });
        setAppNames(names);
      })
      .catch(err => {
        alert("Please enter an app project key");
        setError("Failed to fetch pool data");
        setIsLoading(false);
      });
  };

  return (
    <div className={container}>
      <form className={formStyles}>
        <h2 className={sectionTitle}>App Information</h2>

        <div className={formGroup}>
          <label className={labelStyles}>
            App Project Key <span className={aestric}>*</span>
          </label>
          <input
            type="text"
            className={inputStyles}
            required
            placeholder="Required"
            onChange={(e) => setAppProjectKey(e.target.value)}
          />
        </div>

        <div className={formGroup}>
          <label className={labelStyles}>
            Select an Application
          </label>
          <select
            className={dropdown}
            onChange={(e) => setAppName(e.target.value)}
            required
          >
            <option>Select from applications</option>
            {appNames.map((appName: string, index: number) => (
              <option key={index} value={appName}>
                {appName}
              </option>
            ))}
          </select>
        </div>

        <div className={formGroup}>
          <label className={labelStyles}>
            Service Project Key
          </label>
          <input
            type="text"
            className={inputStyles}
            placeholder="Optional"
            onChange={(e) => setServiceProjectKey(e.target.value)}
          />
        </div>

        <button onClick={Alert} className={buttonStyles}>Submit</button>
      </form>

      {isVisible && (
        <div className={listStyles}>
          <p>Identified the following pools</p>
          <hr />
          <ul>
            {oldPools.map((poolName: string, index: number) => (
              <li key={index}>{poolName}</li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}

export default Entries;





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
          serviceName: '',
          user: '',
          password: ''
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
    <div className={background}>
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
          App name created in "{poolName}" using API: {apiLinks[poolName]}... in progress
        </p>
      ))}
    </div>
  );
};

export default ServicesAndAppsPage;
