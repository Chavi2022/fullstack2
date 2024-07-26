const MigrationContext = createContext<GeneralProps | undefined>(undefined);

export const MigrationProvider: React.FC<{ children: React.ReactNode; value: GeneralProps }> = ({ children, value }) => (
  <MigrationContext.Provider value={value}>{children}</MigrationContext.Provider>
);

export const useMigrationContext = () => {
  const context = useContext(MigrationContext);
  if (context === undefined) {
    throw new Error('useMigrationContext must be used within a MigrationProvider');
  }
  return context;
};
