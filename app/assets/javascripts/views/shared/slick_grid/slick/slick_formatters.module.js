_.defaults(Slick.Formatters, {
    EditableCell: EditableCellFormatter
});

function EditableCellFormatter(row, cell, value, columnDef, dataContext) {
    return "<div class='editable-cell'><span>" + value + "</span><i class='icon-small-pencil'></i></div>";
  }



