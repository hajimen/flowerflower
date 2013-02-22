(function() {
    window.ruby_fix = function(elements) {
        elements.each(
            function() {
                $(this).children("ruby").each(
                    function() {
                        $(this).wrap('<span class="ruby_o"><span class="ruby_i"></span></span>');
                    }
                );
            }
        );
    };
})();

$(document).ready(function() {
    window.ruby_fix($("#content p"));
});