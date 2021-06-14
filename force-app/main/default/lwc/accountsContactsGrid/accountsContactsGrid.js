import { LightningElement, wire } from 'lwc';
import getGridData from '@salesforce/apex/AccountsContactsGridController.getAcctContactData';

export default class AccountsContactsGrid extends LightningElement {
    gridColumns = [
        {
            type: 'url',
            fieldName: 'link',
            label: 'Name',
            typeAttributes: {
                label: { fieldName: 'name' },
            },
            initialWidth: 300,
        },
        {
            type: 'phone',
            fieldName: 'phoneNumber',
            label: 'Phone Number',
        },
        {
            type: 'text',
            fieldName: 'address',
            label: 'City',
        },
        {
            type: 'number',
            fieldName: 'digitalContactsAmount',
            label: '# digital',
            initialWidth: 100,
        },
        {
            type: 'text',
            fieldName: 'department',
            label: 'Department',
        },
    ];
    gridData;
    exceptionData;
    currentExpanded;

    get loading() {
        return !this.gridData && !this.exceptionData;
    }

    @wire(getGridData)
    wiredAcctContactsGridData({data, error}) {
        if (data) {
            this.gridData = JSON.parse(JSON.stringify(data)); // using JSON so I can change the node name
            this.gridData.forEach(obj => this.renameKey( obj, 'contacts', '_children' ));
            this.currentExpanded = this.gridData.map(elem => elem.id);
        } else if (error) {
            console.error(JSON.stringify(error));
            this.exceptionData = error;
        }
    }

    renameKey(obj, oldKey, newKey) {
        obj[newKey] = obj[oldKey];
        delete obj[oldKey];
    }
}