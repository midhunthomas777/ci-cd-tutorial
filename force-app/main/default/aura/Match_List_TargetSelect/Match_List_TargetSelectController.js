/*
 * Copyright (c) 2018  7Summits Inc.
 */
/**
 * Created by francois korb on 5/8/18.
 */
({
	onTargetSelect: function (component, event, helper) {
		let filterString = 'targetId:' + component.get('v.targetId') + ';';

		$A.get("e.c:Match_Filter_Event").setParams({'filterString': filterString}).fire();
	}
});