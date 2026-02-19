/**
 * God Mode JavaScript SDK v1.0.0
 * Universal client for God Mode + Directus APIs
 * 
 * Works with:
 * - Vanilla JavaScript (no dependencies)
 * - CDN React (UMD builds)
 * - Modern bundlers (ESM/CommonJS)
 * 
 * @author Antigravity AI
 * @license MIT
 */

(function (root, factory) {
    if (typeof define === 'function' && define.amd) {
        define([], factory);
    } else if (typeof module === 'object' && module.exports) {
        module.exports = factory();
    } else {
        root.GodMode = factory();
    }
}(typeof self !== 'undefined' ? self : this, function () {
    'use strict';

    /**
     * Main God Mode Client
     */
    class GodModeClient {
        constructor(options = {}) {
            this.baseUrl = options.baseUrl || '';
            this.token = options.token || localStorage.getItem('GOD_MODE_TOKEN') || null;
            this.directusUrl = options.directusUrl || '/items';
        }

        /**
         * Set authentication token
         */
        setToken(token) {
            this.token = token;
            if (token) {
                localStorage.setItem('GOD_MODE_TOKEN', token);
            } else {
                localStorage.removeItem('GOD_MODE_TOKEN');
            }
        }

        // ==================== GOD MODE API ====================

        /**
         * Execute raw SQL query
         * @param {string} sql - SQL query
         * @param {Array} params - Query parameters
         */
        async sql(sql, params = []) {
            return this._godFetch('/api/god/sql', {
                method: 'POST',
                body: JSON.stringify({ sql, params })
            });
        }

        /**
         * Get database connection pool statistics
         */
        async poolStats() {
            return this._godFetch('/api/god/pool/stats');
        }

        /**
         * Check database connection status
         */
        async dbStatus() {
            return this._godFetch('/api/god/db-status');
        }

        /**
         * List all database tables
         */
        async tables() {
            return this._godFetch('/api/god/tables');
        }

        /**
         * Get table schema
         * @param {string} tableName
         */
        async tableSchema(tableName) {
            return this._godFetch(`/api/god/schema/${tableName}`);
        }

        /**
         * Get relationships between tables
         */
        async relationships() {
            return this._godFetch('/api/god/relationships');
        }

        /**
         * Get work logs
         * @param {number} limit
         */
        async logs(limit = 50) {
            return this._godFetch(`/api/god/logs?limit=${limit}`);
        }

        /**
         * Get system health
         */
        async health() {
            return this._fetch('/api/system/health');
        }

        /**
         * Get service status
         */
        async services() {
            return this._godFetch('/api/god/services');
        }

        /**
         * Ingest data
         * @param {Object} data
         */
        async ingest(data) {
            return this._godFetch('/api/god/data/ingest', {
                method: 'POST',
                body: JSON.stringify(data)
            });
        }

        /**
         * Run database mechanic operations
         * @param {string} action - vacuum, analyze, reindex
         */
        async mechanic(action) {
            return this._godFetch(`/api/god/mechanic/execute?action=${action}`, {
                method: 'POST'
            });
        }

        // ==================== DIRECTUS API ====================

        /**
         * Get items from a collection
         * @param {string} collection - Collection name
         * @param {Object} options - Query options
         */
        async getItems(collection, options = {}) {
            const params = new URLSearchParams();

            if (options.limit) params.append('limit', options.limit);
            if (options.offset) params.append('offset', options.offset);
            if (options.page) params.append('page', options.page);
            if (options.filter) params.append('filter', JSON.stringify(options.filter));
            if (options.sort) params.append('sort', Array.isArray(options.sort) ? options.sort.join(',') : options.sort);
            if (options.fields) params.append('fields', Array.isArray(options.fields) ? options.fields.join(',') : options.fields);
            if (options.search) params.append('search', options.search);

            const queryString = params.toString();
            return this._fetch(`${this.directusUrl}/${collection}${queryString ? '?' + queryString : ''}`);
        }

        /**
         * Get single item by ID
         * @param {string} collection
         * @param {string|number} id
         * @param {Array} fields - Optional fields to return
         */
        async getItem(collection, id, fields = null) {
            const params = fields ? `?fields=${fields.join(',')}` : '';
            return this._fetch(`${this.directusUrl}/${collection}/${id}${params}`);
        }

        /**
         * Create new item
         * @param {string} collection
         * @param {Object} data
         */
        async createItem(collection, data) {
            return this._fetch(`${this.directusUrl}/${collection}`, {
                method: 'POST',
                body: JSON.stringify(data)
            });
        }

        /**
         * Update item
         * @param {string} collection
         * @param {string|number} id
         * @param {Object} data
         */
        async updateItem(collection, id, data) {
            return this._fetch(`${this.directusUrl}/${collection}/${id}`, {
                method: 'PATCH',
                body: JSON.stringify(data)
            });
        }

        /**
         * Delete item
         * @param {string} collection
         * @param {string|number} id
         */
        async deleteItem(collection, id) {
            return this._fetch(`${this.directusUrl}/${collection}/${id}`, {
                method: 'DELETE'
            });
        }

        /**
         * Aggregate data
         * @param {string} collection
         * @param {Object} options
         */
        async aggregate(collection, options = {}) {
            const params = new URLSearchParams();
            if (options.aggregate) params.append('aggregate', JSON.stringify(options.aggregate));
            if (options.groupBy) params.append('groupBy', Array.isArray(options.groupBy) ? options.groupBy.join(',') : options.groupBy);
            if (options.filter) params.append('filter', JSON.stringify(options.filter));

            return this._fetch(`${this.directusUrl}/${collection}?${params.toString()}`);
        }

        // ==================== CAMPAIGN API ====================

        /**
         * Get campaigns
         */
        async getCampaigns(siteId = null) {
            const filter = siteId ? { site_id: { _eq: siteId } } : {};
            return this.getItems('campaign_masters', { filter });
        }

        /**
         * Create campaign
         * @param {Object} campaignData
         */
        async createCampaign(campaignData) {
            return this.createItem('campaign_masters', campaignData);
        }

        /**
         * Generate headlines for campaign
         * @param {string} campaignId
         * @param {number} maxHeadlines
         */
        async generateHeadlines(campaignId, maxHeadlines = 1000) {
            return this._fetch('/api/seo/generate-headlines', {
                method: 'POST',
                body: JSON.stringify({ campaign_id: campaignId, max_headlines: maxHeadlines })
            });
        }

        /**
         * Generate articles
         * @param {string} campaignId
         * @param {number} batchSize
         */
        async generateArticles(campaignId, batchSize = 10) {
            return this._fetch('/api/seo/generate-article', {
                method: 'POST',
                body: JSON.stringify({ campaign_id: campaignId, batch_size: batchSize })
            });
        }

        /**
         * Publish article to WordPress
         * @param {string} articleId
         * @param {string} wpSiteUrl
         */
        async publishArticle(articleId, wpSiteUrl) {
            return this._fetch('/api/seo/publish-article', {
                method: 'POST',
                body: JSON.stringify({ article_id: articleId, wp_site_url: wpSiteUrl })
            });
        }

        // ==================== SITES API ====================

        /**
         * Get all sites
         */
        async getSites() {
            return this.getItems('sites');
        }

        /**
         * Get site by ID
         * @param {string} siteId
         */
        async getSite(siteId) {
            return this.getItem('sites', siteId);
        }

        /**
         * Create new site
         * @param {Object} siteData
         */
        async createSite(siteData) {
            return this.createItem('sites', siteData);
        }

        /**
         * Update site
         * @param {string} siteId
         * @param {Object} siteData
         */
        async updateSite(siteId, siteData) {
            return this.updateItem('sites', siteId, siteData);
        }

        // ==================== HELPER METHODS ====================

        /**
         * Make authenticated God Mode API request
         * @private
         */
        async _godFetch(url, options = {}) {
            if (!this.token) {
                throw new Error('God Mode token required. Set via godMode.setToken(token)');
            }
            return this._fetch(url, {
                ...options,
                headers: {
                    'X-God-Token': this.token,
                    ...options.headers
                }
            });
        }

        /**
         * Make HTTP request
         * @private
         */
        async _fetch(url, options = {}) {
            const headers = {
                'Content-Type': 'application/json',
                ...options.headers
            };

            const response = await fetch(this.baseUrl + url, {
                ...options,
                headers
            });

            const contentType = response.headers.get('content-type');
            const isJson = contentType && contentType.includes('application/json');

            if (!response.ok) {
                const error = isJson ? await response.json() : { error: response.statusText };
                throw new Error(error.error || error.message || `HTTP ${response.status}`);
            }

            return isJson ? response.json() : response.text();
        }
    }

    // ==================== REACT COMPONENTS (CDN Compatible) ====================

    if (typeof window !== 'undefined' && window.React && window.ReactDOM) {
        const React = window.React;
        const { useState, useEffect } = React;

        /**
         * Service Status Badge Component
         */
        window.GodModeComponents = window.GodModeComponents || {};

        window.GodModeComponents.ServiceStatus = function ServiceStatus({ serviceName, checkUrl, interval = 10000 }) {
            const [status, setStatus] = useState('checking');
            const [latency, setLatency] = useState(null);

            useEffect(() => {
                const check = async () => {
                    const start = Date.now();
                    try {
                        const res = await fetch(checkUrl);
                        setLatency(Date.now() - start);
                        setStatus(res.ok || res.status === 503 ? 'online' : 'offline');
                    } catch {
                        setStatus('offline');
                        setLatency(null);
                    }
                };

                check();
                const timer = setInterval(check, interval);
                return () => clearInterval(timer);
            }, [checkUrl, interval]);

            const colors = {
                online: 'bg-green-500/10 border-green-500 text-green-400',
                offline: 'bg-red-500/10 border-red-500 text-red-400',
                checking: 'bg-yellow-500/10 border-yellow-500 text-yellow-400'
            };

            const icons = {
                online: '✓',
                offline: '✕',
                checking: '⟳'
            };

            return React.createElement('div', {
                className: `p-4 border-2 rounded-lg ${colors[status]}`
            },
                React.createElement('div', { className: 'flex items-center justify-between' },
                    React.createElement('span', { className: 'font-bold' }, serviceName),
                    React.createElement('span', { className: 'text-2xl' }, icons[status])
                ),
                latency && React.createElement('div', { className: 'text-xs mt-2 opacity-70' }, `${latency}ms`)
            );
        };

        /**
         * SQL Console Component
         */
        window.GodModeComponents.SQLConsole = function SQLConsole({ client }) {
            const [query, setQuery] = useState('SELECT * FROM sites LIMIT 10;');
            const [result, setResult] = useState(null);
            const [loading, setLoading] = useState(false);
            const [error, setError] = useState(null);

            const execute = async () => {
                setLoading(true);
                setError(null);
                try {
                    const res = await (client || window.godMode).sql(query);
                    setResult(res);
                } catch (err) {
                    setError(err.message);
                } finally {
                    setLoading(false);
                }
            };

            return React.createElement('div', { className: 'space-y-4' },
                React.createElement('textarea', {
                    value: query,
                    onChange: (e) => setQuery(e.target.value),
                    className: 'w-full p-4 font-mono bg-black text-green-400 border border-green-500 rounded',
                    rows: 10,
                    placeholder: 'SELECT * FROM sites LIMIT 10;'
                }),
                React.createElement('button', {
                    onClick: execute,
                    disabled: loading,
                    className: 'px-6 py-3 bg-blue-500 text-white rounded hover:bg-blue-600 disabled:opacity-50'
                }, loading ? 'Executing...' : 'Execute Query'),
                error && React.createElement('div', {
                    className: 'p-4 bg-red-500/10 border border-red-500 text-red-400 rounded'
                }, error),
                result && React.createElement('pre', {
                    className: 'p-4 bg-gray-900 text-white rounded overflow-auto max-h-96 text-xs'
                }, JSON.stringify(result, null, 2))
            );
        };

        /**
         * Table Browser Component
         */
        window.GodModeComponents.TableBrowser = function TableBrowser({ client }) {
            const [tables, setTables] = useState([]);
            const [selectedTable, setSelectedTable] = useState(null);
            const [data, setData] = useState(null);
            const [loading, setLoading] = useState(false);

            useEffect(() => {
                (client || window.godMode).tables().then(res => {
                    setTables(res.tables || []);
                });
            }, [client]);

            const loadTable = async (tableName) => {
                setSelectedTable(tableName);
                setLoading(true);
                try {
                    const res = await (client || window.godMode).sql(`SELECT * FROM ${tableName} LIMIT 100`);
                    setData(res);
                } catch (err) {
                    setData({ error: err.message });
                } finally {
                    setLoading(false);
                }
            };

            return React.createElement('div', { className: 'grid grid-cols-4 gap-4' },
                React.createElement('div', { className: 'col-span-1 space-y-2' },
                    React.createElement('h3', { className: 'font-bold mb-4' }, 'Tables'),
                    tables.map(table =>
                        React.createElement('button', {
                            key: table,
                            onClick: () => loadTable(table),
                            className: `w-full text-left px-4 py-2 rounded ${selectedTable === table ? 'bg-blue-500 text-white' : 'bg-gray-800 text-gray-300 hover:bg-gray-700'}`
                        }, table)
                    )
                ),
                React.createElement('div', { className: 'col-span-3' },
                    selectedTable && React.createElement('div', {},
                        React.createElement('h3', { className: 'font-bold mb-4' }, selectedTable),
                        loading && React.createElement('div', {}, 'Loading...'),
                        data && React.createElement('pre', {
                            className: 'p-4 bg-gray-900 text-white rounded overflow-auto max-h-96 text-xs'
                        }, JSON.stringify(data, null, 2))
                    )
                )
            );
        };
    }

    // ==================== AUTO-INITIALIZE ====================

    if (typeof window !== 'undefined') {
        window.godMode = new GodModeClient();
        console.log('🔱 God Mode SDK loaded and ready');
        console.log('Usage: godMode.sql("SELECT * FROM sites LIMIT 10")');
    }

    return GodModeClient;
}));
