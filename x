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
  }),
  table: style({
    width: '100%',
    borderCollapse: 'separate',
    borderSpacing: '0 1px',
  }),
  th: style({
    backgroundColor: '#2a2a2a',
    color: '#ffffff',
    padding: '12px 16px',
    textAlign: 'left',
    fontWeight: 'bold',
    fontSize: '14px',
  }),
  td: style({
    padding: '12px 16px',
    backgroundColor: '#252525',
    color: '#ffffff',
    fontSize: '14px',
  }),
  checkboxCell: style({
    display: 'flex',
    justifyContent: 'center',
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
      content: '"⇅"',
      marginLeft: '4px',
    },
  }),
  envTypeDev: style({
    display: 'inline-block',
    backgroundColor: '#9c27b0',
    color: 'white',
    padding: '2px 6px',
    borderRadius: '4px',
    fontSize: '12px',
  }),
  utilization: style({
    display: 'flex',
    alignItems: 'center',
  }),
  utilizationBar: style({
    height: '8px',
    borderRadius: '4px',
    marginRight: '8px',
  }),
  utilizationText: style({
    minWidth: '36px',
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
};

export const utilizationBarVariants = styleVariants({
  low: { backgroundColor: '#4caf50' },
  medium: { backgroundColor: '#ffc107' },
  high: { backgroundColor: '#ff5722' }
});

export const getUtilizationBarStyle = (percentage: number) => {
  const variantKey = percentage > 70 ? 'high' : percentage > 50 ? 'medium' : 'low';
  return {
    width: `${percentage}%`,
    ...utilizationBarVariants[variantKey]
  };
};

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
  }),
};
