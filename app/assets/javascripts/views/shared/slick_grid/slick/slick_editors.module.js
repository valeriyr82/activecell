_.defaults(Slick.Editors, {
    Select: SelectEditor
});


function SelectEditor(args) {
    var $input, $wrapper;
    var defaultValue, inputValue, defaultId;
    var scope = this;
    var dimension = []

    this.init = function () {
        var $container = $("body");

        $wrapper = $("<DIV class='slick-popup-wrapper'/>")
            .appendTo($container);

        $input = $("<select style='width: 207px;' class='select-dimension'></select>")
            .appendTo($wrapper);

        $wrapper.find("select").bind('change', this.save);

        scope.position(args.position);
        $input.focus().select();
    };

    this.save = function () {
        args.commitChanges();
    };

    this.cancel = function () {
        args.cancelChanges();
    };

    this.hide = function () {
        $wrapper.hide();
    };

    this.show = function () {
        defaultValue = $input[0].options[0].value
        $wrapper.show();
    };

    this.position = function (position) {
        $wrapper
            .css("top", position.top - 7)
            .css("left", position.left - 3)
    };

    this.destroy = function () {
        $wrapper.remove();
    };

    this.focus = function () {
        $input.focus();
    };

    this.loadValue = function (item) {
        var curDim = ''
        switch(item.current_dimension){
            case 'channel':
                curDim = 'segment'
                dimension = app.segments
                break;
            case 'segment':
                curDim = 'channel'
                dimension = app.channels
                break;
        }
        $input[0].options[0] = new Option(item[curDim], item[curDim + '_id'])
        $input[0].options[0].selected = true
        $input[0].options[1] = new Option('Select a' + item.curDim)
        $input[0].options[1].disabled = true
        for (var i = 0; i < dimension.length; i++){
            $input[0].options[2 + i] = new Option(dimension.at(i).get('name'), dimension.at(i).id)
        }
    };

    this.serializeValue = function () {
        return $input.val();
    };

    this.applyValue = function (item, state) {
        args.container.id = dimension.get(state).get('id');
        item[args.column.field] = dimension.get(state).get('name');
    };

    this.isValueChanged = function () {
        inputValue = dimension.get($input.val()).id;
        return inputValue !== defaultValue;
    };

    this.validate = function () {
        return {
            valid: true,
            msg: null
        };
    };

    this.init();
}
