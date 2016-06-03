import ShareModal from './share_modal';
import FavoriteImage from './favorite_image';

const shareModal = new ShareModal('#share_modal');

const favoriteHandler = new FavoriteImage('.js-favorite-image');

favoriteHandler.attachEventHandlers();

shareModal.attachEventHandlers();
