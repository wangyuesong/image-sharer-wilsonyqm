import $ from 'jquery';
import AjaxErrorHandler from './ajax_error_handler'

class FavoriteImage {
  constructor(favoriteSelector) {
    this.$favorite = $(favoriteSelector);
  }

  attachEventHandlers() {
    this.$favorite.on('ajax:success', (event, { desire_favorite_state, count, image_id }) => {
      this.setFavoriteButton(count, desire_favorite_state, image_id);
    });
    this.$favorite.on('ajax:error', (event, {status, responseJSON}) => {
      AjaxErrorHandler(this.$favorite, status, responseJSON)
    });
  }

  setFavoriteButton(count, desire_favorite_state, image_id) {
    var favorite_image = $('.js-image-card').find(`[data-image-id=${image_id}]`);
    if (desire_favorite_state) {
      favorite_image.find('#favorite_btn_fa').attr('class', 'fa fa-heart');
      favorite_image.find('.js-favorite-image').attr('href', `/images/${image_id}/toggle_favorite?desire_favorite_state=false`);
    } else {
      favorite_image.find('#favorite_btn_fa').attr('class', 'fa fa-heart-o');
      favorite_image.find('.js-favorite-image').attr('href', `/images/${image_id}/toggle_favorite?desire_favorite_state=true`);
    }
    favorite_image.find('.js-favorite-count').html(count);
  }
}

export default FavoriteImage;
