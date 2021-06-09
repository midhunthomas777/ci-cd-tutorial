({
    getImageGallery: function (component) {
        var helper = this;
        var GalleryID = component.get('v.GalleryID');
        var params = {
            'imageGalleryIDString': GalleryID
        };
        helper.doCallout(component, 'c.getImageGallery', params).then(function (response) {
            component.set('v.peakResponse', response);
            helper.initCarousel(component);
            component.set('v.isInit', true);
        });
        if(window.location.href.indexOf('livepreview') != -1){
            window.addEventListener('resize', function(){
                helper.initCarousel(component);
            });
        }
    },
    initCarousel: function (component) {
        var dots = component.get('v.optionShowDots');
        var arrows = component.get('v.optionShowArrows');
        var autoplay = component.get('v.optionAutoplay');
        var autoplaySpeed = component.get('v.optionAutoplaySpeed');
        setTimeout(function(){
            $(component.find('slider').getElement()).slick({
                dots: dots,
                infinite: true,
                arrows: arrows,
                speed: 300,
                slidesToShow: 1,
                autoplay: autoplay,
                autoplaySpeed: autoplaySpeed,
                pauseOnDotsHover: true,
                respondTo: 'min'
            });
        });
    }
})