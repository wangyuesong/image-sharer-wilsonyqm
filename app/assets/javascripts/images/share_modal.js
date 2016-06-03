import $ from 'jquery';
import setFlashMessage from './set_flash_message'
import generalErrorHandler from './general_error_handler'
import {UNPROCESSABLE_ENTITY} from './http_status_const';

class ShareModal {
  constructor(modalSelector) {
    this.$modal = $(modalSelector);
    this.blankShareModalHtml = this.$modal.html();
  }

  setupModal({imageId, imageUrl}) {
    const formAction = this.$modal.find('form').attr('action');
    this.$modal.find('form').attr('action', formAction.replace(':id', imageId));
    this.$modal.find('img').attr('src', imageUrl);
  }

  attachEventHandlers() {
    this.$modal.on('show.bs.modal', event => {
      const modalTrigger = event.relatedTarget;
      this.setupModal(modalTrigger.dataset);
    });
    this.$modal.on('hidden.bs.modal', () => {
      this.$modal.html(this.blankShareModalHtml);
    });
    this.$modal.on('ajax:success', () => {
      setFlashMessage('success', 'Shared it!');
      this.$modal.modal('hide');
    });
    this.$modal.on('ajax:error', (event, {status, responseJSON}) => {
      if (status == UNPROCESSABLE_ENTITY) {
        this.$modal.find('form').replaceWith(responseJSON.form_html);
      } else {
        generalErrorHandler(status);
      }
    });
  }
}

export default ShareModal;
