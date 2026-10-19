import { s__ } from '~/locale';
import FeatureLibraryItem from '~/super_sidebar/components/feature_library/feature_library_item.vue';

const originalTierLabel = FeatureLibraryItem.computed.tierLabel;

FeatureLibraryItem.computed.tierLabel = function tierLabel() {
  if (this.item.tier === 'team') {
    return s__('JH|License|Team');
  }

  return originalTierLabel.call(this);
};
