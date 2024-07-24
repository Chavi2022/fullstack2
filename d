let sidGlobal: string = "";
let passGlobal: string = "";

function LoginPage(): JSX.Element {
  const [sid, setSID] = useState<string>('');
  const [pass, setPass] = useState<string>('');
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    try {
      const response = await axios.post('http://localhost:8080/api/login', { user: sid, password: pass });
      if (response.status === 200) {
        navigate('/landing');
      } else {
        console.error('Login failed');
      }
    } catch (error) {
      console.error('Login failed', error);
    }
  };

  const handleClick = () => {
    sidGlobal = sid;
    passGlobal = pass;
  };

  return (
    <div className={appContainer}>
      <Navbar message="" />
      <div className={loginContainer}>
        <h1>Log In</h1>
        <form onSubmit={handleSubmit} className={gridForm}>
          <label className={leftColumn}>
            User SID:
            <input
              id="button"
              className={inputBox}
              type="text"
              placeholder="SID"
              value={sid}
              onChange={(e) => setSID(e.target.value)}
              required
            />
          </label>
          <label className={leftColumn}>
            Password:
            <input
              className={inputBox}
              type="password"
              placeholder="Password"
              value={pass}
              onChange={(e) => setPass(e.target.value)}
              required
            />
          </label>
          <label>
            <input type="checkbox" />
            Remember me?
          </label>
          <a className={anchorLink} href="/#">SSO Login</a>
          <button type="submit" className={submitButton} onClick={handleClick}>Log in</button>
        </form>
      </div>
    </div>
  );
}

export function getSID(): string {
  return sidGlobal;
}

export function getPass(): string {
  return passGlobal;
}

export default LoginPage;
