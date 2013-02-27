$(document).ready(function() { 
    function fontAvailable(fontName) {
	    $('body').append('<p id="font_available_p" style="visibility:hidden; font-size:16px"><span id="font_available_span">abcdefghijklmnopqrstuvwxyz</span></p>');
        var element = $('#font_available_span');
        var width = element
            .css('font-family', '__FAKEFONT__')
            .width();
        var height = element.height();
        
        element.css('font-family', fontName);
        
        var ret = (width !== element.width() || height !== element.height());
        $('#font_available_p').remove();
        return ret;
    }

    function rubyAvailable() {
	    $('body').append('<p id="meiryo_fix_p" style="visibility:hidden; font-size:16px"><ruby id="meiryo_fix_ruby">試験<rp>あいうえお</rp><rt>テスト</rt><rp>あいうえお</rp></ruby></p>');
	    var test_width = $('#meiryo_fix_ruby').width();
	    $('#meiryo_fix_p').remove();
        return (test_width < 60);
    }

    if(fontAvailable('メイリオ') && rubyAvailable()) {
        $("#content p").each(
            function() {
                $(this).children("ruby").each(
                    function() {
                        $(this).wrap('<span class="ruby_o"><span class="ruby_i"></span></span>');
                    }
                );
            }
        );
        $('head').append('<link rel="stylesheet" href="../meiryo/meiryo_fix.css" type="text/css" />');
    }
});
