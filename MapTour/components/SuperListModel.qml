import QtQuick 2.5

ListModel {
    id: superListModel
    property string sortProperty
    property string sortOrder: kSortOrderAsc
    property int sortCaseSensitivity: Qt.CaseInsensitive

    readonly property string kSortOrderAsc: "asc"
    readonly property string kSortOrderDesc: "desc"

    property ListModel sourceModel
    property string filterProperty
    property string filterText
    property int baseItems: 0
    property bool debug: false

    function appendEx(jsObject){
        superListModel.append(jsObject)
        sourceModel.append(jsObject)
    }

    function recovery(){
        syncSource()
    }

    function insertEx(index, jsObject){
        if(index<superListModel.count)superListModel.insert(index, jsObject)
        else console.log("invalid insert index for visual model")

        if(index<source.count)sourceModel.append(jsObject)
        else console.log("invalid insert index for source model")
    }

    //--------------------------------------------------------------------------

    function sort(begin, end)
    {
        if (!(sortProperty > "")) {
            console.error("Empty sortProperty");
            return;
        }

        if (begin === undefined) {
            begin = 0;
        }

        if (end === undefined) {
            end = count;
        }

        qsort(begin, end);
    }

    //--------------------------------------------------------------------------

    function qsort(begin, end)
    {
        if (end - 1 > begin) {
            var pivot = begin + Math.floor(Math.random() * (end - begin));

            pivot = partition(begin, end, pivot);

            qsort(begin, pivot);
            qsort(pivot + 1, end);
        }
    }

    //--------------------------------------------------------------------------

    function partition(begin, end, pivot)
    {
        var pivotValue = get(pivot)[sortProperty];
        if (sortCaseSensitivity === Qt.CaseInsensitive) {
            pivotValue = toCaseInsensitive(pivotValue);
        }

        swap(pivot, end - 1);
        var store = begin;

        for (var index = begin; index < end - 1; index++) {
            var indexValue = get(index)[sortProperty];
            if (sortCaseSensitivity === Qt.CaseInsensitive) {
                indexValue = toCaseInsensitive(indexValue);
            }

            if (sortOrder === kSortOrderAsc && indexValue < pivotValue) {
                swap(store, index);
                store++;
            } else if (sortOrder === kSortOrderDesc && indexValue > pivotValue) {
                swap(store, index);
                store++;
            }
        }

        swap(end - 1, store);

        return store;
    }

    //--------------------------------------------------------------------------

    function swap(a, b) {
        if (a < b) {
            move(a, b, 1);
            move(b - 1, a, 1);
        }
        else if (a > b) {
            move(b, a, 1);
            move(a - 1, b, 1);
        }
    }

    //--------------------------------------------------------------------------

    function toCaseInsensitive(value) {
        if (!value) {
            return value;
        }

        if (typeof value !== "string") {
            return value;
        }

        return value.toString().toLocaleLowerCase();
    }

    //--------------------------------------------------------------------------

    function toggleSortOrder() {
        sortOrder = sortOrder === kSortOrderAsc ? kSortOrderDesc : kSortOrderAsc;
    }

    //--------------------------------------------------------------------------

    onFilterTextChanged: {
        filter();
    }

    //--------------------------------------------------------------------------

    function filter() {

        if (!sourceModel) {
            console.warn("Undefined filtered sourceModel");
            return;
        }

        if (!(filterText > "")) {
            syncSource()
            sort(0)
            return;
        }

        if (!(filterProperty>"")) {
            syncSource()
            sort(0)
            return;
        }

        clear();

        var filterPattern = new RegExp(filterText, "i");

        var item;
        for (var i = baseItems; i < sourceModel.count; i++ ) {
            item = sourceModel.get(i);

            var insert = false;

            if (!insert && item[filterProperty] > "" && item[filterProperty].search(filterPattern) >= 0) {
                insert = true;
            }

            if (insert) {
                append(item);
            }
        }

        sort(0)
    }

    //--------------------------------------------------------------------------

    function sortModel(modelToSort, sortingProperty, sortingOrder) {
        clear()
        sourceModel = modelToSort;
        sortProperty = sortingProperty;
        sortOrder = sortingOrder;
        syncSource();
        sort();

        modelToSort.clear()
        for(var i=0; i<count; i++) {
            modelToSort.append(get(i));
        }
    }

    //--------------------------------------------------------------------------

    function syncSource(){
        clear()
        if (sourceModel) {
            for( var i = 0; i < sourceModel.count; i++){
                append(sourceModel.get(i))
            }
        }
    }

    Component.onCompleted: {
        syncSource()
    }

}
