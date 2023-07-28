/*! @preserve
 * bstreeview.js
 * Version: 1.2.1
 * Authors: Sami CHNITER <sami.chniter@gmail.com>
 * Copyright 2020
 * License: Apache License 2.0
 *
 * Project: https://github.com/jonmiles/bootstrap-treeview (bootstrap 3)
 *        : https://jonmiles.github.io/bootstrap-treeview/
 * Project: https://github.com/chniter/bstreeview (bootstrap 4)
 * Project: https://github.com/nhmvienna/bs5treeview (bootstrap 5)  (nanobot uses this version)
 */
; (function ($, window, document, undefined) {
    "use strict";
    /**
     * Default bstreeview  options.
     */
    var pluginName = "bstreeview",
        defaults = {
            expandIcon: 'fa fa-angle-down fa-fw',
            collapseIcon: 'fa fa-angle-right fa-fw',
            expandClass: 'show',
            indent: 1.25,
            parentsMarginLeft: '1.25rem',
            openNodeLinkOnNewTab: true

        };
    /**
     * bstreeview HTML templates.
     */
    var templates = {
        treeview: '<div class="bstreeview"></div>',
        treeviewItem: '<div role="treeitem" class="list-group-item" data-bs-toggle="collapse"></div>',
        treeviewGroupItem: '<div role="group" class="list-group collapse" id="itemid"></div>',
        treeviewItemStateIcon: '<i class="state-icon"></i>',
        treeviewItemIcon: '<i class="item-icon"></i>'
    };
    /**
     * BsTreeview Plugin constructor.
     * @param {*} element
     * @param {*} options
     */
    function bstreeView(element, options) {
        this.element = element;
        this.itemIdPrefix = element.id + "-item-";
        this.settings = $.extend({}, defaults, options);
        this.init();
    }
    /**
     * Avoid plugin conflict.
     */
    $.extend(bstreeView.prototype, {
        /**
         * bstreeview intialize.
         */
        init: function () {
            this.tree = [];
            this.nodes = [];
            // Retrieve bstreeview Json Data.
            if (this.settings.data) {
                if (this.settings.data.isPrototypeOf(String)) {
                    this.settings.data = $.parseJSON(this.settings.data);
                }
                this.tree = $.extend(true, [], this.settings.data);
                delete this.settings.data;
            }
            // Set main bstreeview class to element.
            $(this.element).addClass('bstreeview');

            this.initData({ nodes: this.tree });
            var _this = this;

            this.build($(this.element), this.tree, 0);
            // Update angle icon on collapse
            $(this.element).on('click', '.list-group-item', function (e) {
                $('.state-icon', this)
                    .toggleClass(_this.settings.expandIcon)
                    .toggleClass(_this.settings.collapseIcon);
                // navigate to href if present
                if (e.target.hasAttribute('href')) {
                    if (_this.settings.openNodeLinkOnNewTab) {
                        window.open(e.target.getAttribute('href'), '_blank');
                    }
                    else {
                        window.location = e.target.getAttribute('href');
                    }
                }
                else
                {
                    // Toggle the data-bs-target. Issue with Bootstrap toggle and dynamic code
                    $($(this).attr("data-bs-target")).collapse('toggle');
                }
            });
        },
        /**
         * Initialize treeview Data.
         * @param {*} node
         */
        initData: function (node) {
            if (!node.nodes) return;
            var parent = node;
            var _this = this;
            $.each(node.nodes, function checkStates(index, node) {

                node.nodeId = _this.nodes.length;
                node.parentId = parent.nodeId;

                node.state = node.state || {};

                _this.nodes.push(node);

                if (node.nodes) {
                    _this.initData(node);
                }
            });
        },
        /**
         * Build treeview.
         * @param {*} parentElement
         * @param {*} nodes
         * @param {*} depth
         */
        build: function (parentElement, nodes, depth) {
            var _this = this;
            // Calculate item padding.
            var leftPadding = _this.settings.parentsMarginLeft;

            if (depth > 0) {
                leftPadding = (_this.settings.indent + depth * _this.settings.indent).toString() + "rem;";
            }
            depth += 1;
            // Add each node and sub-nodes.
            $.each(nodes, function addNodes(id, node) {
                // Main node element.
                var treeItem = $(templates.treeviewItem)
                    .attr('data-bs-target', "#" + _this.itemIdPrefix + node.nodeId)
                    .attr('style', 'padding-left:' + leftPadding)
                    .attr('aria-level', depth);
                // Set Expand and Collapse icones.
                if (node.nodes) {
                    var treeItemStateIcon = $(templates.treeviewItemStateIcon)
                        .addClass((node.expanded)?_this.settings.expandIcon:_this.settings.collapseIcon);
                    treeItem.append(treeItemStateIcon);
                }

                // highlight searched node
                if (node.searchResult) {
                    treeItem.addClass('search-result');
                    treeItem.focus();
                }

                // set node icon if exist.
                if (node.icon) {
                    var treeItemIcon = $(templates.treeviewItemIcon)
                        .addClass(node.icon);
                    treeItem.append(treeItemIcon);
                }
                // Set node Text.
                treeItem.append(node.text);
                // Reset node href if present
                if (node.href) {
                    treeItem.attr('href', node.href);
                }
                // Add class to node if present
                if (node.class) {
                    treeItem.addClass(node.class);
                }
                // Add custom id to node if present
                if (node.id) {
                    treeItem.attr('id', node.id);
                }
                // Attach node to parent.
                parentElement.append(treeItem);
                // Build child nodes.
                if (node.nodes) {
                    // Node group item.
                    var treeGroup = $(templates.treeviewGroupItem)
                        .attr('id', _this.itemIdPrefix + node.nodeId);
                    parentElement.append(treeGroup);
                    _this.build(treeGroup, node.nodes, depth);
                    if (node.expanded) {
                        treeGroup.addClass(_this.settings.expandClass);
                    }
                }
            });
        },

        search: function (pattern) {
            this.clearSearch();

            // pattern is accession id now
            var results = this.findNodes(pattern, 'gi', 'text');
            // Add searchResult property to all matching nodes
            // This will be used to apply custom styles
            // and when identifying result to be cleared
            $.each(results, function (index, node) {
                node.searchResult = true;
            });
            this.revealNode(results);

			return results;
        },

        clearSearch : function (options) {
            var results = $.each(this.findNodes('true', 'g', 'searchResult'), function (index, node) {
                node.searchResult = false;
                node.expanded = false;
            });
        },

        findNodes: function (pattern, modifier, attribute) {
            modifier = modifier || 'g';
            attribute = attribute || 'text';

            var _this = this;
            return $.grep(this.nodes, function (node) {
                var val = _this.getNodeValue(node, attribute);
                if (typeof val === 'string') {
                    //return val.match(new RegExp(pattern, modifier));
                    return val == pattern;
                }
            });
        },

        identifyNode : function (identifier) {
            return ((typeof identifier) === 'number') ?
                            this.nodes[identifier] :
                            identifier;
        },

        getNodeValue: function (obj, attr) {
            var index = attr.indexOf('.');
            if (index > 0) {
                var _obj = obj[attr.substring(0, index)];
                var _attr = attr.substring(index + 1, attr.length);
                return this.getNodeValue(_obj, _attr);
            }
            else {
                if (obj.hasOwnProperty(attr)) {
                    return obj[attr].toString();
                }
                else {
                    return undefined;
                }
            }
        },

        revealNode : function (identifiers, options) {
            this.forEachIdentifier(identifiers, options, $.proxy(function (node, options) {
                var parentNode = this.getParent(node);
                while (parentNode) {
                    this.setExpandedState(parentNode, true, options);
                    parentNode = this.getParent(parentNode);
                };
            }, this));

            this.render();
        },

        forEachIdentifier : function (identifiers, options, callback) {
            options = {};

            if (!(identifiers instanceof Array)) {
                identifiers = [identifiers];
            }

            $.each(identifiers, $.proxy(function (index, identifier) {
                callback(this.identifyNode(identifier), options);
            }, this));
            },

            getParent : function (identifier) {
                var node = this.identifyNode(identifier);
                return this.nodes[node.parentId];
            },

            identifyNode : function (identifier) {
                return ((typeof identifier) === 'number') ?
                                this.nodes[identifier] :
                                identifier;
        },

        setExpandedState : function (node, state, options) {
            //if (state === node.state.expanded) return;
            if (state === node.expanded) return;

            if (state && node.nodes) {

                // Expand a node
                //node.state.expanded = true;
                node.expanded = true;
            }
            else if (!state) {

                // Collapse a node
                //node.state.expanded = false;
                node.expanded = false;

                // Collapse child nodes
                if (node.nodes && !options.ignoreChildren) {
                    $.each(node.nodes, $.proxy(function (index, node) {
                        this.setExpandedState(node, false, options);
                    }, this));
                }
            }
        },

        render : function () {
//            if (!this.initialized) {
//
//                // Setup first time only components
//                this.$element.addClass(pluginName);
//                this.$wrapper = $(this.template.list);
//
//                this.injectStyle();
//
//                this.initialized = true;
//            }

            //this.$element.empty().append(this.$wrapper.empty());
            $(this.element).empty();
            // Build tree
            this.build($(this.element), this.tree, 0);
        }





    });

    // A really lightweight plugin wrapper around the constructor,
    // preventing against multiple instantiations
    $.fn[pluginName] = function (options) {
        return this.each(function () {
            //if (!$.data(this, "plugin_" + pluginName)) {
                $.data(this, "plugin_" +
                    pluginName, new bstreeView(this, options));
            //}
        });
    };
})(jQuery, window, document);
