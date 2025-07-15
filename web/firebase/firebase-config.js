// Firebase configuration for web
// This file should be updated with your actual Firebase project configuration

const firebaseConfig = {
  // Replace with your Firebase project configuration
  apiKey: 'AIzaSyBfWlxiDCGFDBH9FDUaPYfIQPsSxxHA5uY',
  authDomain: 'trinixcore-dev.firebaseapp.com',
  projectId: 'trinixcore-dev',
  storageBucket: 'trinixcore-dev.firebasestorage.app',
  messagingSenderId: '540292179997',
  appId: '1:540292179997:web:9079028023240342693ef4',
  measurementId: 'G-SZHSJ97421'
};

// Initialize Firebase
import { initializeApp } from 'firebase/app';
import { getAnalytics } from 'firebase/analytics';

const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);

export { app, analytics }; 