import { style, styleVariants } from '@vanilla-extract/css';

export const tablestyles = {
  container: style({
    width: '100%',
    maxWidth: '1600px',
    margin: '2rem auto',
    backgroundColor: '#e1e1e1',
    borderRadius: '8px',
    overflow: 'hidden',
    fontFamily: 'Arial, sans-serif',
    textAlign: 'center',
  }),
  table: style({
    width: '100%',
    borderCollapse: 'collapse',
  }),
  th: style({
    backgroundColor: '#2a2a2a',
    color: '#ffffff',
    padding: '12px 16px',
    textAlign: 'center',
    fontWeight: 'bold',
    fontSize: '14px',
  }),
  td: style({
    padding: '12px 16px',
    backgroundColor: '#252525',
    color: '#ffffff',
    fontSize: '14px',
    textAlign: 'center',
  }),
  tr: style({
    ':hover': {
      backgroundColor: '#ffffff', // White background on hover
      color: '#000000', // Black text color on hover
    },
  }),
  showSelectedButton: style({
    marginTop: '20px',
    padding: '12px 20px',
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
  selectedPools: style({
    listStyleType: 'none',
    paddingLeft: 0,
  }),
  confirmedPools: style({
    listStyleType: 'none',
    paddingLeft: 0,
  }),
  deleteButton: style({
    marginLeft: '10px',
    padding: '5px 10px',
    backgroundColor: '#f44336',
    color: 'white',
    border: 'none',
    borderRadius: '5px',
    cursor: 'pointer',
    fontSize: '12px',
    ':hover': {
      backgroundColor: '#da2f2f',
    },
  }),
  utilizationBarContainer: style({
    backgroundColor: '#e1e1e1',
    borderRadius: '5px',
    overflow: 'hidden',
    position: 'relative',
    height: '20px',
  }),
  utilizationBar: style({
    height: '100%',
    borderRadius: '5px',
    textAlign: 'center',
    lineHeight: '20px',
    color: 'white',
  }),
};

export const utilizationBarVariants = styleVariants({
  low: {
    backgroundColor: '#4CAF50', // Green
  },
  medium: {
    backgroundColor: '#FFC107', // Yellow
  },
  high: {
    backgroundColor: '#F44336', // Red
  },
});

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
    maxWidth: '580px',
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
      backgroundColor: '#da2f2f',
    },
  }),
  migrateButton: style({
    marginTop: '20px',
    padding: '10px 20px',
    backgroundColor: '#2196F3',
    color: 'white',
    border: 'none',
    borderRadius: '5px',
    cursor: 'pointer',
    fontSize: '16px',
    ':hover': {
      backgroundColor: '#1976D2',
    },
    ':disabled': {
      backgroundColor: '#c0c0c0',
      cursor: 'not-allowed',
    },
  }),
};
