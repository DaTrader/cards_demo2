import {
  newListill,
  prepForSorting,
  completeListill,
  applyCall,
  initApplyCall,
  deinitApplyCall,
} from "../../deps/phoenix_live_view_ext/assets/js/listiller";


/*******
 * Hooks
 */

export { ListillContainerHook, ListillTailHook, ListillItemHook};

/*
 * Default listiller container hook used for convenience when there's no need to customize it with changes.
 */
const ListillContainerHook = newListillContainerHook();

/*
 * Hook to use with the tail list element that _must_ a singleton child within its listiller container and
 * must listed last (after all listed elements).
 * The tail element expects to find its listill container by loooking for the 'listill' attribute.
 */
const ListillTailHook = {
  mounted: function() {
    assocListillContainerHookData( this);
    _completeListill( this);
  },
  updated: function() {
    _completeListill( this);
  }
};

/*
 * Hook to use with every sorted item in a listilled list.
 */
const ListillItemHook = {
  mounted: function() {
    assocListillContainerHookData( this);
    _prepForSorting( this);
  },
  updated: function() {
    _prepForSorting( this);
  }
};


/**
 * Returns a ListillerContainerHook with optionally applied changes.
 * Changes:
 * - Providing isNotifyRemoval function may be useful to filter elements that need to be notified before removal.
 *   The function takes an element and returns boolean.
 * - Uses sortAttr as suffix in `data-${sortAttr}` if provided, otherwise defaults to `data-sort`.
 * - Uses deleteSelector if provided relative to the listiller container element, otherwise defaults
 *   to `div[data-delete]`.
 */
function newListillContainerHook( changes = {}) {
  return {
    mounted: function() {
      this._listill = {
        state: newListill(
          changes.sortAttr || 'sort',
          changes.deleteSelector || 'div[data-delete]',
          changes.isNotifyRemoval || null
        )
      };
      initApplyCall( this);
    },
    destroyed: function() {
      deinitApplyCall( this);
    }
  };
}


/**
 * Applies call to the listiller container that will have the container's hook data associated with the child's.
 * @param childHookData
 */
function assocListillContainerHookData( childHookData) {
  const container = findListillContainer( childHookData.el);

  applyCall(
    container.id,
    containerHookData => _updateHookData(
      childHookData,
      childListillData => childListillData.containerHookData = containerHookData
    )
  );
}

function _completeListill( tailHookData) {
  completeListill( containerListillState( tailHookData), _containerHookData( tailHookData).el);
}

function containerListillState( childHookData) {
  return _containerHookData( childHookData)._listill.state;
}

function _containerHookData( childHookData) {
  return childHookData._listill.containerHookData;
}

function _prepForSorting( itemHookData) {
  return prepForSorting(
    containerListillState( itemHookData),
    itemHookData.el,
    id => id
  );
}

function _updateHookData( hookData, updater) {
  if( !hookData._listill) {
    hookData._listill = {};
  }

  updater( hookData._listill);
}


/**
 * Finds the closes ancestor having a listill attribute or null if not found.
 */
function findListillContainer( elem) {
  return _findAncestor( elem, el => el.hasAttribute( 'listill'));
}

/**
 * Returns the element ancestor matching the provided function or null if not found.
 */
function _findAncestor( el, isMatch) {
  while( el && !isMatch( el)) el = el.parentElement;
  return el;
}
