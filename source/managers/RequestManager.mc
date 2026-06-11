using Toybox.Communications;
using Toybox.Application;
using Toybox.Json;
using Toybox.System;
import Toybox.Lang;
using Toybox.PersistedContent;

(:glance)
class RequestManagerResponseHandler {
    private var callback;
    private var manager;

    function initialize(callback, manager) {
        me.callback = callback;
        me.manager = manager;
    }

    function onReceive(responseCode as Number, data as Dictionary or String or PersistedContent.Iterator or Null) as Void {
        var success = (responseCode >= 200 && responseCode <= 304);
        
        if (me.callback != null) {
            if (me.callback instanceof Lang.Method) {
                try {
                    me.callback.invoke({
                        :success => success,
                        :code => responseCode,
                        :data => success ? data : null
                    });
                } catch (ex) {
                    writeLog("ResponseHandler:onReceive", "Callback invoke crashed: " + ex.getErrorMessage(), 100);
                }
            } else {
                writeLog("ResponseHandler:onReceive", "Callback not a Method", 100);
            }
        }

        // Notify manager to process the next item in the FIFO queue
        if (me.manager != null) {
            try {
                // Check if manager still exists and has the method
                if (me.manager has :_onRequestComplete) {
                    me.manager._onRequestComplete();
                }
            } catch (ex) {
                writeLog("ResponseHandler:onReceive", "Notify manager failed: " + ex.getErrorMessage(), 100);
            }
        }
    }
}

(:glance)
class RequestManager {
    private var apiKey;
    private var hosturl;

    private var _ongoing = 0;
    private var _queue = [] as Array<Dictionary>;
    private const MAX_CONCURRENT = 3;

    function initialize() {
        var app = Application.getApp();
        apiKey = app.getProperty("apikey");
        var host = app.getProperty("sparkyfithost");
        hosturl = "https://" + (host != null ? host : "");
    }

    function get(endpoint, params, callback) {
        makeRequest(endpoint, params, Communications.HTTP_REQUEST_METHOD_GET, callback);
    }

    function post(endpoint, params, callback) {
        makeRequest(endpoint, params, Communications.HTTP_REQUEST_METHOD_POST, callback);
    }

    function put(endpoint, params, callback) {
        makeRequest(endpoint, params, Communications.HTTP_REQUEST_METHOD_PUT, callback);
    }

    function delete(endpoint, callback) {
        makeRequest(endpoint, null, Communications.HTTP_REQUEST_METHOD_DELETE, callback);
    }

    private function makeRequest(endpoint, paramsss, httpMethod, callback) {
        var params = (paramsss == null) ? {} : paramsss;

        // FIFO Check: If we are at capacity, push to the back of the queue array
        if (me._ongoing >= me.MAX_CONCURRENT) {
            var entry = {
                :endpoint => endpoint,
                :params => params,
                :method => httpMethod,
                :callback => callback
            };
            me._queue.add(entry);
            writeLog("RequestManager:makeRequest", "Queued request: " + endpoint.toString() + " | Queue Size: " + me._queue.size(), 50);
            return;
        }

        me._executeRequest(endpoint, params, httpMethod, callback);
    }

    private function _executeRequest(endpoint, params, httpMethod, callback) as Void {
        me._ongoing += 1;

        var url = hosturl + endpoint;
        var options = {
            :method => httpMethod,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
                "Authorization" => "Bearer " + (apiKey != null ? apiKey.toString() : "")
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
        };
        writeLog("RequestManager:_executeRequest", "Making request: " + endpoint.toString() + " | Ongoing: " + me._ongoing, 50);
        var responseHandler = new RequestManagerResponseHandler(callback, me);
        Communications.makeWebRequest(url, params, options, responseHandler.method(:onReceive));
    }

    function _onRequestComplete() as Void {
        me._ongoing -= 1;
        if (me._ongoing < 0) { me._ongoing = 0; }

        // FIFO Execution: Process the front of the queue (Index 0)
        if (me._queue.size() > 0) {
            var next = me._queue[0];
            
            // Correct way to "shift/remove" the first item from an array in Monkey C
            me._queue = me._queue.slice(1, me._queue.size());

            if (next != null) {
                var cb = next.get(:callback);
                var endpointVal = next.get(:endpoint);
                var paramsVal = next.get(:params);
                var methodVal = next.get(:method);
                
                writeLog("RequestManager:_onRequestComplete", "Dequeuing request: " + endpointVal, 50);
                me._executeRequest(endpointVal, paramsVal, methodVal, cb);
            }
        }
    }
}