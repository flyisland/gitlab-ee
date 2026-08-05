import { GlLoadingIcon } from '@gitlab/ui';
import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import BoardView from '~/work_items/board/board_view.vue';
import ColumnGroup from '~/work_items/board/components/column_group.vue';
import getBoardNamespaceStatusesQuery from 'ee_else_ce/work_items/board/graphql/get_namespace_statuses.query.graphql';
import namespaceWorkItemTypesQuery from '~/work_items/graphql/namespace_work_item_types.query.graphql';
import updateBoardWorkItemMutation from '~/work_items/board/graphql/update_board_work_item.mutation.graphql';
import { statusStrategy } from 'ee/work_items/board/grouping/status_strategy';
import { boardColumnQueryVariables, boardColumnCountVariables } from '~/work_items/board/utils';
import { RELATIVE_POSITION_ASC } from '~/work_items/list/constants';
import {
  addWorkItemToColumn,
  adjustWorkItemCountInColumn,
  readWorkItemFromColumn,
  readWorkItemsFromColumn,
  removeWorkItemFromColumn,
} from '~/work_items/board/graphql/cache_updates';
import {
  buildStatus,
  buildNamespaceStatusesResponse,
  buildWorkItemNode,
  buildWorkItemTypesResponse,
} from 'jest/work_items/board/mock_data';

jest.mock('~/sentry/sentry_browser_wrapper');
jest.mock('~/work_items/board/graphql/cache_updates');

Vue.use(VueApollo);

describe('BoardView', () => {
  let wrapper;
  let toast;

  const statusesQueryHandler = jest.fn();
  const workItemTypesQueryHandler = jest.fn();
  const updateMutationHandler = jest.fn();

  const defaultStatuses = [
    buildStatus(1, 'To do', 'to_do'),
    buildStatus(2, 'In progress', 'in_progress'),
    buildStatus(3, 'Done', 'done'),
  ];
  // The board always enforces Manual sort, so position persistence is active.
  const queryVariables = { state: 'opened', sort: RELATIVE_POSITION_ASC };

  const columnVariables = (value) =>
    boardColumnQueryVariables({
      rootPageFullPath: 'full/path',
      baseQueryVariables: queryVariables,
      columnFilter: { status: { name: value.name } },
    });

  const columnCountVariables = (value) =>
    boardColumnCountVariables({
      rootPageFullPath: 'full/path',
      baseQueryVariables: queryVariables,
      groupProperty: 'status',
      value,
    });

  const findLoadingIcon = () => wrapper.findComponent(GlLoadingIcon);
  const findColumnGroups = () => wrapper.findAllComponents(ColumnGroup);

  const createComponent = ({ props = {} } = {}) => {
    toast = { show: jest.fn() };
    const apolloProvider = createMockApollo([
      [getBoardNamespaceStatusesQuery, statusesQueryHandler],
      [namespaceWorkItemTypesQuery, workItemTypesQueryHandler],
      [updateBoardWorkItemMutation, updateMutationHandler],
    ]);

    wrapper = shallowMountExtended(BoardView, {
      apolloProvider,
      mocks: { $toast: toast },
      propsData: {
        rootPageFullPath: 'full/path',
        queryVariables,
        ...props,
      },
    });
  };

  beforeEach(() => {
    statusesQueryHandler.mockResolvedValue(buildNamespaceStatusesResponse(defaultStatuses));
    workItemTypesQueryHandler.mockResolvedValue(buildWorkItemTypesResponse());
    updateMutationHandler.mockResolvedValue({
      data: { workItemUpdate: { workItem: buildWorkItemNode(1), errors: [] } },
    });
  });

  describe('loading state', () => {
    it('renders the loading icon while the query is loading and no values are present', () => {
      createComponent();

      expect(findLoadingIcon().exists()).toBe(true);
      expect(findColumnGroups()).toHaveLength(0);
    });

    it('hides the loading icon once the query resolves', async () => {
      createComponent();
      await waitForPromises();

      expect(findLoadingIcon().exists()).toBe(false);
    });
  });

  describe('column groups', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('renders one ColumnGroup per status node', () => {
      expect(findColumnGroups()).toHaveLength(defaultStatuses.length);
    });

    it('passes value, strategy, rootPageFullPath, and baseQueryVariables to each ColumnGroup', () => {
      findColumnGroups().wrappers.forEach((columnGroup, index) => {
        expect(columnGroup.props()).toMatchObject({
          value: defaultStatuses[index],
          rootPageFullPath: 'full/path',
          baseQueryVariables: queryVariables,
        });
        expect(columnGroup.props('strategy').property).toBe('status');
      });
    });

    it('renders no ColumnGroups when the query returns no statuses', async () => {
      statusesQueryHandler.mockResolvedValue(buildNamespaceStatusesResponse([]));
      createComponent();
      await waitForPromises();

      expect(findColumnGroups()).toHaveLength(0);
    });

    it('orders the columns by status category', async () => {
      statusesQueryHandler.mockResolvedValue(
        buildNamespaceStatusesResponse([
          buildStatus(1, 'Cancelled', 'canceled'),
          buildStatus(2, 'Done', 'done'),
          buildStatus(3, 'Triage', 'triage'),
          buildStatus(4, 'In progress', 'in_progress'),
          buildStatus(5, 'To do', 'to_do'),
        ]),
      );
      createComponent();
      await waitForPromises();

      expect(findColumnGroups().wrappers.map((group) => group.props('value').name)).toEqual([
        'Triage',
        'To do',
        'In progress',
        'Done',
        'Cancelled',
      ]);
    });
  });

  describe('collapsed groups', () => {
    const groupId = (status) => `status:${status.id}`;

    it('marks only columns whose group id is in collapsedGroups as collapsed', async () => {
      createComponent({ props: { collapsedGroups: [groupId(defaultStatuses[1])] } });
      await waitForPromises();

      expect(findColumnGroups().wrappers.map((group) => group.props('collapsed'))).toEqual([
        false,
        true,
        false,
      ]);
    });

    it('defaults every column to expanded when collapsedGroups is empty', async () => {
      createComponent();
      await waitForPromises();

      expect(findColumnGroups().wrappers.map((group) => group.props('collapsed'))).toEqual([
        false,
        false,
        false,
      ]);
    });

    it('emits toggle-collapse with the group id when a column requests it', async () => {
      createComponent();
      await waitForPromises();

      findColumnGroups().at(2).vm.$emit('toggle-collapse');

      expect(wrapper.emitted('toggle-collapse')).toEqual([[groupId(defaultStatuses[2])]]);
    });
  });

  describe('when selecting a card', () => {
    it('opens the detail work item panel', async () => {
      const activeItem = buildWorkItemNode(1);
      createComponent();
      await waitForPromises();

      findColumnGroups().at(0).vm.$emit('set-active-item', activeItem);

      expect(wrapper.emitted('set-active-item')).toEqual([[activeItem]]);
    });
  });

  describe('visible groups', () => {
    const groupId = (status) => `status:${status.id}`;

    it('renders every column when visibleGroups is null (the default)', async () => {
      createComponent();
      await waitForPromises();

      expect(findColumnGroups()).toHaveLength(defaultStatuses.length);
    });

    it('renders only the columns whose group id is in visibleGroups', async () => {
      createComponent({
        props: { visibleGroups: [groupId(defaultStatuses[0]), groupId(defaultStatuses[2])] },
      });
      await waitForPromises();

      expect(findColumnGroups().wrappers.map((group) => group.props('value').name)).toEqual([
        'To do',
        'Done',
      ]);
    });

    it('renders no columns when visibleGroups is empty', async () => {
      createComponent({ props: { visibleGroups: [] } });
      await waitForPromises();

      expect(findColumnGroups()).toHaveLength(0);
    });
  });

  describe('drag and drop', () => {
    const fromStatus = defaultStatuses[0];
    const toStatus = defaultStatuses[1];
    const movedNode = buildWorkItemNode(1);

    const dragEvent = ({ from = fromStatus, to = toStatus, oldIndex = 0, newIndex = 0 } = {}) => ({
      from: { dataset: { groupValueId: from.id } },
      to: { dataset: { groupValueId: to.id } },
      item: { dataset: { workItemId: movedNode.id } },
      oldIndex,
      newIndex,
    });

    const emitCardMove = (event) => findColumnGroups().at(0).vm.$emit('card-move', event);

    beforeEach(async () => {
      readWorkItemFromColumn.mockReturnValue(movedNode);
      createComponent();
      await waitForPromises();
    });

    it('persists the move with the target status', async () => {
      emitCardMove(dragEvent());
      await waitForPromises();

      expect(updateMutationHandler).toHaveBeenCalledWith(
        expect.objectContaining({
          input: { id: movedNode.id, statusWidget: { status: toStatus.id } },
        }),
      );
    });

    it('optimistically moves the card from the source column to the target column', async () => {
      emitCardMove(dragEvent());
      await waitForPromises();

      expect(removeWorkItemFromColumn).toHaveBeenCalledWith(
        expect.objectContaining({
          variables: columnVariables(fromStatus),
          workItemId: movedNode.id,
        }),
      );
      expect(addWorkItemToColumn).toHaveBeenCalledWith(
        expect.objectContaining({
          variables: columnVariables(toStatus),
          workItem: movedNode,
          index: 0,
          patchCard: expect.any(Function),
        }),
      );
    });

    it('decrements the source column count and increments the target column count', async () => {
      emitCardMove(dragEvent());
      await waitForPromises();

      expect(adjustWorkItemCountInColumn).toHaveBeenCalledWith(
        expect.objectContaining({ variables: columnCountVariables(fromStatus), delta: -1 }),
      );
      expect(adjustWorkItemCountInColumn).toHaveBeenCalledWith(
        expect.objectContaining({ variables: columnCountVariables(toStatus), delta: 1 }),
      );
    });

    it('does nothing when the card is dropped in its original column', () => {
      emitCardMove(dragEvent({ to: fromStatus }));

      expect(updateMutationHandler).not.toHaveBeenCalled();
      expect(removeWorkItemFromColumn).not.toHaveBeenCalled();
      expect(addWorkItemToColumn).not.toHaveBeenCalled();
      expect(adjustWorkItemCountInColumn).not.toHaveBeenCalled();
    });

    it('does nothing when the moved card is not in the cache', () => {
      readWorkItemFromColumn.mockReturnValue(null);

      emitCardMove(dragEvent());

      expect(updateMutationHandler).not.toHaveBeenCalled();
    });

    it('persists a same-column reorder with relative position and no status change', async () => {
      const columnNodes = [buildWorkItemNode(1), buildWorkItemNode(2), buildWorkItemNode(3)];
      readWorkItemsFromColumn.mockReturnValue(columnNodes);

      emitCardMove(dragEvent({ to: fromStatus, oldIndex: 0, newIndex: 2 }));
      await waitForPromises();

      expect(updateMutationHandler).toHaveBeenCalledWith(
        expect.objectContaining({
          input: { id: movedNode.id, moveBeforeId: columnNodes[2].id },
        }),
      );
      expect(addWorkItemToColumn).toHaveBeenCalledWith(
        expect.objectContaining({
          variables: columnVariables(fromStatus),
          index: 2,
          patchCard: null,
        }),
      );
    });

    it('includes relative position alongside the status change on a cross-column move', async () => {
      const columnNodes = [buildWorkItemNode(10), buildWorkItemNode(11)];
      readWorkItemsFromColumn.mockReturnValue(columnNodes);

      emitCardMove(dragEvent({ newIndex: 1 }));
      await waitForPromises();

      expect(updateMutationHandler).toHaveBeenCalledWith(
        expect.objectContaining({
          input: {
            id: movedNode.id,
            statusWidget: { status: toStatus.id },
            moveBeforeId: columnNodes[0].id,
            moveAfterId: columnNodes[1].id,
          },
        }),
      );
    });

    it('disables dragging until the move mutation resolves', async () => {
      let resolveMutation;
      updateMutationHandler.mockReturnValue(
        new Promise((resolve) => {
          resolveMutation = resolve;
        }),
      );

      expect(findColumnGroups().at(0).props('dragDisabled')).toBe(false);

      emitCardMove(dragEvent());
      await nextTick();

      expect(findColumnGroups().at(0).props('dragDisabled')).toBe(true);

      resolveMutation({
        data: { workItemUpdate: { workItem: buildWorkItemNode(1), errors: [] } },
      });
      await waitForPromises();

      expect(findColumnGroups().at(0).props('dragDisabled')).toBe(false);
    });

    describe('when the board is not sorted manually', () => {
      const columnNodes = [buildWorkItemNode(1), buildWorkItemNode(2), buildWorkItemNode(3)];

      beforeEach(async () => {
        readWorkItemsFromColumn.mockReturnValue(columnNodes);
        createComponent({ props: { queryVariables: { ...queryVariables, sort: 'CREATED_DESC' } } });
        await waitForPromises();
      });

      it('does not persist a same-column reorder', () => {
        emitCardMove(dragEvent({ to: fromStatus, oldIndex: 0, newIndex: 2 }));

        expect(updateMutationHandler).not.toHaveBeenCalled();
      });

      it('persists the status change without relative position on a cross-column move', async () => {
        emitCardMove(dragEvent({ newIndex: 1 }));
        await waitForPromises();

        expect(updateMutationHandler).toHaveBeenCalledWith(
          expect.objectContaining({
            input: { id: movedNode.id, statusWidget: { status: toStatus.id } },
          }),
        );
      });
    });

    it('shows a toast and captures the error when the mutation returns errors', async () => {
      updateMutationHandler.mockResolvedValue({
        data: { workItemUpdate: { workItem: null, errors: ['nope'] } },
      });

      emitCardMove(dragEvent());
      await waitForPromises();

      expect(toast.show).toHaveBeenCalledWith(
        'Something went wrong while updating the work item. Please try again.',
      );
      expect(Sentry.captureException).toHaveBeenCalled();
    });

    it('shows a toast and captures the error when the mutation rejects', async () => {
      updateMutationHandler.mockRejectedValue(new Error('network'));

      emitCardMove(dragEvent());
      await waitForPromises();

      expect(toast.show).toHaveBeenCalledWith(
        'Something went wrong while updating the work item. Please try again.',
      );
      expect(Sentry.captureException).toHaveBeenCalled();
    });
  });

  describe('drag eligibility gate', () => {
    const workItem = {
      id: 'gid://gitlab/WorkItem/1',
      workItemType: { id: 'gid://gitlab/WorkItems::Type/1' },
    };

    const startDrag = (item = workItem) => findColumnGroups().at(0).vm.$emit('drag-start', item);

    it('fetches gate data via the strategy gate query', async () => {
      createComponent({ props: { rootPageFullPath: 'group/subgroup' } });
      await waitForPromises();

      expect(workItemTypesQueryHandler).toHaveBeenCalledWith({ fullPath: 'group/subgroup' });
    });

    it('disables only the columns the strategy reports the dragged item cannot enter', async () => {
      // Gate the drop deterministically; the status-specific data logic lives in
      // status_strategy_spec (isDropAllowed / extractGateData).
      jest
        .spyOn(statusStrategy, 'isDropAllowed')
        .mockImplementation(({ value }) => value.id === defaultStatuses[0].id);
      createComponent();
      await waitForPromises();

      startDrag();
      await nextTick();

      expect(findColumnGroups().at(0).props('dropDisabled')).toBe(false);
      expect(findColumnGroups().at(1).props('dropDisabled')).toBe(true);
    });

    it('clears the disabled columns once a card move ends', async () => {
      jest
        .spyOn(statusStrategy, 'isDropAllowed')
        .mockImplementation(({ value }) => value.id === defaultStatuses[0].id);
      createComponent();
      await waitForPromises();

      startDrag();
      await nextTick();
      findColumnGroups().at(0).vm.$emit('card-move', { oldIndex: 0, newIndex: 0 });
      await nextTick();

      expect(findColumnGroups().wrappers.every((c) => c.props('dropDisabled') === false)).toBe(
        true,
      );
    });

    it('disables no columns when the type has no recorded status constraint', async () => {
      createComponent();
      await waitForPromises();

      startDrag();
      await nextTick();

      expect(findColumnGroups().wrappers.every((c) => c.props('dropDisabled') === false)).toBe(
        true,
      );
    });
  });

  describe('statuses query', () => {
    it('calls the statuses query with rootPageFullPath', async () => {
      createComponent({ props: { rootPageFullPath: 'group/subgroup' } });
      await nextTick();

      expect(statusesQueryHandler).toHaveBeenCalledWith({ fullPath: 'group/subgroup' });
    });
  });

  describe('when the statuses query errors', () => {
    const queryError = new Error('GraphQL failure');

    beforeEach(async () => {
      statusesQueryHandler.mockRejectedValue(queryError);
      createComponent();
      await waitForPromises();
    });

    it('captures the error in Sentry', () => {
      expect(Sentry.captureException).toHaveBeenCalledWith(queryError);
    });

    it('emits set-error with a user-facing message', () => {
      expect(wrapper.emitted('set-error')).toEqual([
        ['Something went wrong when fetching the board columns. Please try again.'],
      ]);
    });

    it('renders no ColumnGroups', () => {
      expect(findColumnGroups()).toHaveLength(0);
    });

    it('hides the loading icon', () => {
      expect(findLoadingIcon().exists()).toBe(false);
    });
  });
});
