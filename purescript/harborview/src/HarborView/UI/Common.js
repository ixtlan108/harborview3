"use strict";

export const randomHtmlIdStr = function() {
  return Math.random().toString(36).slice(2, 7);
}