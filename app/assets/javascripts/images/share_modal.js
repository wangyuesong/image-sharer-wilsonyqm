import $ from 'jquery';
import setFlashMessage from './set_flash_message'
import AjaxErrorHandler from './ajax_error_handler'

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
      AjaxErrorHandler(this.$modal, status, responseJSON);
    });
  }
}

export default ShareModal;
