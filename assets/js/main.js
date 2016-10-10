"use strict";


$( document ).ready( function() {



  // Ajoute target="_blank" aux liens externes.
  ( function() {
    var internal = location.host.replace( "www.", "" );
    internal = new RegExp( internal, "i" );
    var a = document.getElementsByTagName( 'a' );
    for( var i = 0; i < a.length; i++ ) {
      var href = a[ i ].host;
      if( !internal.test( href ) ) {
        a[ i ].setAttribute( 'target', '_blank' );
      }
    }
  })();




  // Navigation avec le clavier.
  ( function() {
    var menuLinks = $( "ul.nav li" );
    console.log( "menuLinks = ", menuLinks );
    var nbLinks = menuLinks.length;
    var activeLinkIndex = $( "ul.nav li.active" ).first().index();
    var nextLink = $( menuLinks[ activeLinkIndex < (nbLinks - 1) ? activeLinkIndex + 1 : 0           ] ).children( "a" ).attr( 'href' );
    var prevLink = $( menuLinks[ activeLinkIndex > 0             ? activeLinkIndex - 1 : nbLinks - 1 ] ).children( "a" ).attr( 'href' );
    var firstLink = $( "ul.nav li" ).first().children( "a" ).attr( 'href' );

    $( 'a#bouton-prec' ).attr( "href", prevLink );
    $( 'a#bouton-suiv' ).attr( "href", nextLink );


    Mousetrap.bind( 'left',       function( e ) { navigate_to_page( e, prevLink  ); });
    Mousetrap.bind( 'esc',        function( e ) { navigate_to_page( e, firstLink ); });
    Mousetrap.bind( 'right',      function( e ) { navigate_to_page( e, nextLink  ); });

    $( 'body' ).on( 'mousedown',  function( e ) { disable_swipe( e ); });
    $( 'body' ).on( 'touchstart', function( e ) { enable_swipe( e );  });

    var navigate_to_page = function( e, targetHref ) {
      window.location.href = targetHref;
    }
    function disable_swipe( e ) {
      $( 'body' ).off( 'swiperight swipeleft' );
    }
    function enable_swipe( e ) {
      $( 'body' ).on( 'swiperight', function( e ) { navigate_to_page( e, prevLink ); });
      $( 'body' ).on( 'swipeleft',  function( e ) { navigate_to_page( e, nextLink ); });
    }
  })();

});
