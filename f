import { style } from "@vanilla-extract/css";

export const container = style({
  width: "84%",
  background: "#212121",
  border: "solid 2px #313131",
  padding: "20px",
  margin: "50px auto",
  borderRadius: "10px",
  color: "#fff",
  boxShadow: "0 4px 8px rgba(0, 0, 0, 0.1)",
});

export const formStyles = style({
  display: "flex",
  flexDirection: "column",
  gap: "20px",
});

export const formGroup = style({
  display: "flex",
  alignItems: "center",
});

export const labelStyles = style({
  flex: "1",
  textAlign: "right",
  marginRight: "10px",
});

export const inputStyles = style({
  flex: "2",
  padding: "10px",
  borderRadius: "5px",
  border: "1px solid #ccc",
  fontSize: "16px",
  color: "#212121",
  boxSizing: "border-box",
});

export const dropdown = style({
  flex: "2",
  padding: "10px",
  borderRadius: "5px",
  border: "1px solid #ccc",
  fontSize: "16px",
  color: "#212121",
  boxSizing: "border-box",
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
