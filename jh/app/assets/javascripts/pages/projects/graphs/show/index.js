import initContributorsGraphs from '~/contributors';
import jhInitContributorsGraphs from 'jh/contributors';

if (gon.features.linesOfCode) {
  jhInitContributorsGraphs();
} else {
  initContributorsGraphs();
}
