import {NOT_FOUND, UNAUTHORIZED} from './http_status_const';

export default function generalErrorHandler(status) {
  if (status == NOT_FOUND) {
    window.location = '/';
  } else if (status == UNAUTHORIZED) {
    window.location = '/login';
  } else {
    alert('Sorry, an unexpected error occurred. Please try again');
  }
}
