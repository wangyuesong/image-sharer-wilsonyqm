const UNPROCESSABLE_ENTITY = 422;
const NOT_FOUND = 404;
const UNAUTHORIZED = 401;

export default function AjaxErrorHandler(selector, status, responseJSON) {
  if (status == UNPROCESSABLE_ENTITY) {
    selector.find('form').replaceWith(responseJSON.form_html);
  } else if (status == NOT_FOUND) {
    window.location = '/';
  } else if (status == UNAUTHORIZED) {
    window.location = '/login';
  } else {
    alert('Sorry, an unexpected error occurred. Please try again');
  }
}
