/**
 * @format
 */

import ReactTestRenderer from 'react-test-renderer';
import App from '../App';

jest.mock('react-native-get-location', () => ({
  __esModule: true,
  default: {
    getCurrentPosition: jest.fn(),
    openSettings: jest.fn(),
  },
  isLocationError: jest.fn(() => false),
}));

jest.mock(
  'react-native-safe-area-context',
  () => require('react-native-safe-area-context/jest/mock').default,
);

test('renders correctly', async () => {
  await ReactTestRenderer.act(() => {
    ReactTestRenderer.create(<App />);
  });
});
