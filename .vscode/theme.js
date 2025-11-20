// const logger = (() => {
//     const logPrefix = '[theme]';
//     return {
//         log: (...args) => console.log(logPrefix, ...args),
//         warn: (...args) => console.warn(logPrefix, ...args),
//         error: (...args) => console.error(logPrefix, ...args),
//     };
// })();

// // Clone the Profile and Settings icons from the activity bar and add them to the titlebar
// function addIconsToTitlebar() {
//     const titlebarRight = document.querySelector('.titlebar-right .actions-container');
//     if (!titlebarRight) {
//         return false;
//     }

//     if (titlebarRight.querySelector('.titlebar-profile-icon') &&
//         titlebarRight.querySelector('.titlebar-settings-icon')) {
//         return true;
//     }

//     const profileIcon = document.querySelector('.part.activitybar .codicon-accounts-view-bar-icon')?.closest('.action-item');
//     const settingsIcon = document.querySelector('.part.activitybar .codicon-settings-view-bar-icon')?.closest('.action-item');

//     // Only proceed if both icons are found
//     if (!profileIcon || !settingsIcon) {
//         return false;
//     }

//     const profileClone = profileIcon.cloneNode(true);
//     const settingsClone = settingsIcon.cloneNode(true);
//     profileClone.classList.add('titlebar-profile-icon');
//     settingsClone.classList.add('titlebar-settings-icon');

//     titlebarRight.querySelectorAll('.titlebar-profile-icon, .titlebar-settings-icon').forEach(el => el.remove());

//     // Separator between the original titlebar and our added icons
//     const separator = document.createElement('div');
//     separator.classList.add('separator');
//     separator.setAttribute('role', 'separator');
//     separator.setAttribute('aria-hidden', 'true');
//     titlebarRight.appendChild(separator);

//     titlebarRight.appendChild(settingsClone);
//     titlebarRight.appendChild(profileClone);

//     profileIcon.style.display = 'none';
//     settingsIcon.style.display = 'none';

//     // logger.log('Successfully added profile and settings icons to titlebar');
//     return true;
// }

// // Try to add icons immediately
// addIconsToTitlebar();

// const persistentObserver = new MutationObserver(() => {
//     addIconsToTitlebar();
// });

// const titlebarRight = document.querySelector('.titlebar-right');
// if (titlebarRight) {
//     persistentObserver.observe(titlebarRight, {
//         childList: true,
//         subtree: true
//     });
//     // logger.log('Persistent observer attached to titlebar');
// } else {
//     const initialObserver = new MutationObserver(() => {
//         const titlebar = document.querySelector('.titlebar-right');
//         if (titlebar) {
//             addIconsToTitlebar();
//             persistentObserver.observe(titlebar, {
//                 childList: true,
//                 subtree: true
//             });
//             initialObserver.disconnect();
//             // logger.log('Titlebar found, persistent observer attached');
//         }
//     });

//     initialObserver.observe(document.body, {
//         childList: true,
//         subtree: true
//     });
// }

/*
(function () {
	function patch() {
		const e1 = document.querySelector(".right-items");
		const e2 = document.querySelector(".right-items .__CUSTOM_CSS_JS_INDICATOR_CLS");
		if (e1 && !e2) {
			let e = document.createElement("div");
			e.id = "be5invis.vscode-custom-css";
			e.title = "Custom CSS and JS";
			e.className = "statusbar-item right __CUSTOM_CSS_JS_INDICATOR_CLS";
			{
				const a = document.createElement("a");
				a.tabIndex = -1;
				a.className = 'statusbar-item-label';
				{
					const span = document.createElement("span");
					span.className = "codicon codicon-paintcan";
					a.appendChild(span);
				}
				e.appendChild(a);
			}
			e1.appendChild(e);
		}
	}
	setInterval(patch, 5000);
})();
*/

function waitUntil(condition) {
	return new Promise((resolve) => {
		const check = () => {
			if (condition()) {
				resolve();
			} else {
				requestAnimationFrame(check);
			}
		};

		check();
	});
}

document.addEventListener("DOMContentLoaded", async () => {
	await waitUntil(() => document.querySelector(".right-items"));

    // Remove the custom CSS watermark added by the extension
    const observer = new MutationObserver((mutations) => {
		for (const mutation of mutations) {
			for (const node of mutation.addedNodes) {
				if (node.id === "be5invis.vscode-custom-css") {
					console.log('[theme] removing custom CSS watermark');
					node.remove();
				}
			}
		}
        });
    });

    const rightItems = document.querySelector(".right-items");
    if (rightItems) {
        console.log('attached');
        observer.observe(rightItems, { childList: true, subtree: true });
        const existing = document.getElementById("be5invis.vscode-custom-css");
        existing?.remove();
	}
});