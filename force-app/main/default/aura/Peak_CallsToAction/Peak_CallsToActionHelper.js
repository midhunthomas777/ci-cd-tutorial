({
    initComponent : function(component, event, helper){
        var title = component.get('v.title');
        var layout = component.get('v.layout');
        var vAlign = component.get('v.verticalAlign');
        var tAlign = component.get('v.textAlign');
        var tTrans = component.get('v.textTransform');
        var fontSize = component.get('v.fontSize');
        var total = parseInt(component.get('v.totalItems'));
        if(fontSize == ''){
            component.set('v.fontSize', '1rem');
        }

        component.set('v.verticalAlign', this.getPosition(vAlign));
        component.set('v.horizontalAlign', this.getPosition(tAlign));
        component.set('v.textAlign', tAlign.toLowerCase());
        component.set('v.textTransform', tTrans.toLowerCase());
        component.set('v.total', total);

        this.setRowWidths(component, event, helper);

        this.createList(component, total, layout);
        component.set('v.isInit', true);
    },
    setColor : function(component, color, type){
        if(color == '' || color == undefined){
            if(type == 'back'){
                color = component.get('v.ctaDefaultBack');
            }else if(type == 'text'){
                color = component.get('v.ctaDefaultColor');
            }else{
                color = component.get('v.ctaDefaultIconColor');
            }
        }
        return color;
    },
    setRowWidths: function(component, event, helper) {
        var itemsPerRowBase = component.get("v.itemsPerRowBase");
        var itemsPerRowSmall = component.get("v.itemsPerRowSmall");
        var itemsPerRowMedium = component.get("v.itemsPerRowMedium");
        var itemsPerRowLarge = component.get("v.itemsPerRowLarge");
        // If value is "auto", set that value, otherwise divide by 2.
        component.set("v._rowWidthBase", itemsPerRowBase === 'auto' ? 'auto' : 12 / itemsPerRowBase);
        component.set("v._rowWidthSmall", itemsPerRowSmall === 'auto' ? 'auto' : 12 / itemsPerRowSmall);
        component.set("v._rowWidthMedium", itemsPerRowMedium === 'auto' ? 'auto' : 12 / itemsPerRowMedium);
        component.set("v._rowWidthLarge", itemsPerRowLarge === 'auto' ? 'auto' : 12 / itemsPerRowLarge);
    },
    getPosition : function (input) {
        if(input == 'Top' || input == 'Left'){
            input ='start';
        }else if(input == 'Bottom' || input == 'Right'){
            input ='end';
        }else{
            input = 'center';
        }
        return input;
    },
    createList : function (component, total, layout) {
        var itemList = [];
        var height = component.get('v.ctaHeight');
        var iconFont = 0;
        if(height.indexOf('px') != -1){
            iconFont = parseInt(height.replace('px', ''))/75*100;
        }else if(height.indexOf('em') != -1){
            iconFont = parseInt(height.replace('em', ''))*16/75*100;
        }else{
            iconFont = height;
        }
        component.set('v.iconFont', iconFont + '%');
        if(layout == 'Base Layout'){
            for(var i = 1; i <= total; i++){
                var ctaText = component.get('v.ctaText' + i);
                var ctaDesc = component.get('v.ctaDesc' + i);
                var ctaBackgroundColor = component.get('v.ctaBackgroundColor' + i);
                var ctaTextColor = component.get('v.ctaTextColor' + i);
                ctaBackgroundColor = this.setColor(component, ctaBackgroundColor, 'back');
                ctaTextColor = this.setColor(component, ctaTextColor, 'text');
                itemList.push({
                    'ctaText': ctaText,
                    'ctaDesc': ctaDesc,
                    'url': component.get('v.ctaURL' + i),
                    'image': component.get('v.ctaImage' + i),
                    'backSize': component.get('v.ctaBackgroundSize' + i),
                    'backColor': ctaBackgroundColor,
                    'textColor': ctaTextColor,
                    'overlay': component.get('v.ctaOverlay' + i)
                });
            }
        }else{
            for(var i = 1; i <= total; i++){
                var text = '';
                var ctaText = component.get('v.ctaText' + i);
                var image = component.get('v.ctaImage' + i);
                var useText = component.get('v.useText' + i);
                var useIcon = false;
                var ctaBackgroundColor = component.get('v.ctaBackgroundColor' + i);
                var ctaTextColor = component.get('v.ctaTextColor' + i);
                var iconColor = component.get('v.iconColor' + i);
                ctaBackgroundColor = this.setColor(component, ctaBackgroundColor, 'back');
                ctaTextColor = this.setColor(component, ctaTextColor, 'text');
                iconColor = this.setColor(component, iconColor, 'icon');
                if(useText){
                    text = image.substring(0, 4).toUpperCase();
                }else{
                    var imageHolder = image.toLowerCase();
                    if(imageHolder.indexOf('action:') != -1 || imageHolder.indexOf('custom:') != -1 || imageHolder.indexOf('doctype:') != -1 || imageHolder.indexOf('standard:') != -1 || imageHolder.indexOf('utility:') != -1){
                        useIcon = true;
                        var imageElements = imageHolder.split(':');
                        var category = imageElements[0];
                        image = imageElements[1];
                    }else{
                        if(image === 'Item '+ i + ' Image' || image === undefined){
                            image = '';
                        }
                    }
                }
                itemList.push({
                    'ctaText': ctaText,
                    'text': text,
                    'url': component.get('v.ctaURL' + i),
                    'useIcon': useIcon,
                    'useText': useText,
                    'iconColor': iconColor,
                    'category': category,
                    'image': image,
                    'backSize': component.get('v.ctaBackgroundSize' + i),
                    'backColor': ctaBackgroundColor,
                    'textColor': ctaTextColor,
                    'overlay': component.get('v.ctaOverlay' + i)
                });
            }
        }
        component.set('v.itemList', itemList);
    }
})