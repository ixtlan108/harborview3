"use strict";

/*
export const setTableItemSelected = (item) => (isSelected) => {
  return function () {
    item.selected = isSelected;
  };
};
*/

export const setSelected = (item) => (isSelected) => {
  item.selected = isSelected;
};

export const setRisc = (item) => (risc) => {
  item.risc = risc;
};
