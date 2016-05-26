import $ from 'jquery';

const NOT_FOUND = 404;
const UNAUTHORIZED = 401;

class FavoriteImage {
  constructor(modalSelector) {
    this.$favorite = $(modalSelector);
  }

  attachEventHandlers() {
    this.$favorite.on('ajax:success', (event, { desire_favorite_state, count, image_id }) => {
        this.setFavoriteButton(count, desire_favorite_state, image_id);
    });
    this.$favorite.on('ajax:error', (event, {status, responseJSON}) => {
          console.log('AJAX ERROR');
          if (status == NOT_FOUND) {
            window.location = '/';
          } else if (status == UNAUTHORIZED) {
            window.location = '/login';
          } else {
            alert('Sorry, an unexpected error occurred. Please try again');
          }
        });
  }

  setFavoriteButton(count, desire_favorite_state, image_id) {
    var favorite_image = $('.js-image-card').find(`[data-image-id=${image_id}]`);
    if (desire_favorite_state) {
      favorite_image.find('#favorite_btn_fa').attr('class', 'fa fa-heart');
      favorite_image.find('.js-favorite-image').attr('href', `/images/${image_id}/favorite_toggle?desire_favorite_state=false`);
    } else {
      favorite_image.find('#favorite_btn_fa').attr('class', 'fa fa-heart-o');
      favorite_image.find('.js-favorite-image').attr('href', `/images/${image_id}/favorite_toggle?desire_favorite_state=true`);
    }
    favorite_image.find('.js-favorite-count').html(count);
  }
}

export default FavoriteImage;
