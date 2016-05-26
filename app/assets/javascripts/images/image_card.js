import ShareModal from './share_modal';
import FavoriteImage from './favorite_image';

const shareModal = new ShareModal('#share_modal');

const favoriteImage = new FavoriteImage('.js-favorite-image');

favoriteImage.attachEventHandlers();

shareModal.attachEventHandlers();
