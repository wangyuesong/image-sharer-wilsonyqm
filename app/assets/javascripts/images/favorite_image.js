import $ from 'jquery';
import generalErrorHandler from './general_error_handler'

const favorite_btn_count = document.getElementById('favorite_btn_count').innerHTML;

class FavoriteImage {
  constructor(favoriteSelector) {
    this.$favorite = $(favoriteSelector);
  }

  attachEventHandlers() {
    this.$favorite.on('ajax:success', (event, { desire_favorite_state, count, image_id }) => {
      this.setFavoriteButton(count, desire_favorite_state, image_id);
    });
    this.$favorite.on('ajax:error', (event, {status}) => {
      generalErrorHandler(status)
    });
  }

  setFavoriteButton(count, desire_favorite_state, image_id) {
    const favorite_image = $('.js-image-card').find(`[data-image-id=${image_id}]`);
    const favorite_icon = favorite_image.find('.js-favorite-fa');
    const favorite_count = favorite_image.find('.js-favorite-count');
    const new_favorite_count = favorite_btn_count.replace('{some_count}', count);
    if (desire_favorite_state) {
      favorite_icon.removeClass('fa-heart-o').addClass('fa-heart');
    } else {
      favorite_icon.removeClass('fa-heart').addClass('fa-heart-o');
    }
    favorite_count.replaceWith(new_favorite_count);
  }
}

export default FavoriteImage;
