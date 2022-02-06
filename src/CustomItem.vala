using Gtk;

public class CustomItem {

  private static const int icon_size = 32;

  private Cairo.Surface? _surface = null;

  public CanvasItem? item { get; private set; default = null; }

  /* Default constructor */
  public CustomItem() {
    item     = null;
    _surface = null;
  }

  /* Constructor */
  public CustomItem.with_item( CanvasItem item ) {
    double x1, y1, x2, y2;
    item.get_extents( out x1, out y1, out x2, out y2 );
    this.item = item.duplicate();
    this.item.move_item( (0 - x1), (0 - y1), false );
    this.item.mode = CanvasItemMode.NONE;
    create_surface();
  }

  /* Returns the image associated with this item */
  public Image get_image() {
    var image = new Image.from_surface( _surface );
    return( image );
  }

  /* Create an icon from the item */
  private void create_surface() {
    if( item != null ) {
      var src = new Cairo.ImageSurface( Cairo.Format.A8, icon_size, icon_size );
     	var ctx = new Cairo.Context( src );
      var it  = item.duplicate();
      double x1, y1, x2, y2;
      it.get_extents( out x1, out y1, out x2, out y2 );
      var scale_x = (icon_size * 1.0) / (x2 - x1);
      var scale_y = (icon_size * 1.0) / (y2 - y1);
      if( scale_x < scale_y ) {
        ctx.scale( scale_x, scale_x );
        ctx.translate( 0, (icon_size - ((y2 - y1) * scale_y)) );
      } else {
        ctx.scale( scale_y, scale_y );
        ctx.translate( (icon_size - ((x2 - x1) * scale_x)), 0 );
      }
      it.draw_item( ctx );
      _surface = src;

    }
  }

  /* Saves this item as XML format */
  public Xml.Node* save() {
    Xml.Node* node = new Xml.Node( null, "custom-item" );
    node->add_child( item.save() );
    return( node );
  }

  /* Loads this item from XML format */
  public void load( Xml.Node* node, CanvasItems canvas_items ) {
    for( Xml.Node* it=node->children; it!=null; it=it->next ) {
      if( (it->type == Xml.ElementType.ELEMENT_NODE) && (it->name == "item") ) {
        item = canvas_items.load_item( it );
        create_surface();
      }
    }
  }

}