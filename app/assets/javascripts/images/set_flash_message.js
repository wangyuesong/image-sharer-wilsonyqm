export default function setFlashMessage(type, message) {
  document.getElementById('flash_messages').innerHTML =
    `<div class="alert alert-${type} %>">${message}</div>`;
}
