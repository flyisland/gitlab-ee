import $ from 'jquery';

$(() => {
  const mergeMethods = $('input[name="project[merge_method]"]');
  const squashOptions = $('input[name="project[project_setting_attributes][squash_option]"]');

  const onMergeMethodsChange = () => {
    const isSingleSquashMerge = mergeMethods.filter(':checked').val() === 'single_squash_merge';
    if (isSingleSquashMerge) {
      squashOptions.filter('[value=always]').prop('checked', true);
    }

    squashOptions.prop('disabled', isSingleSquashMerge);
  };

  mergeMethods.on('change', onMergeMethodsChange);
  onMergeMethodsChange();
});
