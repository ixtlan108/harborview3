"use strict";

/*
export const setTableItemSelected = (item) => (isSelected) => {
  return function () {
    item.selected = isSelected;
  };
};
*/

export const setTableItemSelected = (item) => (isSelected) => {
  item.selected = isSelected;
};
