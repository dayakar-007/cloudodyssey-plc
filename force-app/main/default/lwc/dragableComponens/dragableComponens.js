import { LightningElement } from 'lwc';

export default class DragableComponens extends LightningElement {
    sections = [
        { id: 'A', label: 'Section A' },
        { id: 'B', label: 'Section B' },
        { id: 'C', label: 'Section C' }
    ];

    draggedItemId;

    handleDragStart(event) {
        this.draggedItemId = event.target.dataset.id;
        console.log('🔵 Drag Start → Dragged Item ID:', this.draggedItemId);
    }

    handleDragOver(event) {
        event.preventDefault();
        console.log('🟡 Drag Over → Target ID:', event.target.dataset.id);
    }

    handleDrop(event) {
        const droppedOnId = event.target.dataset.id;
        console.log('🟢 Drop Event');
        console.log('   🔸 Dragged ID:', this.draggedItemId);
        console.log('   🔸 Dropped On ID:', droppedOnId);

        if (this.draggedItemId === droppedOnId) {
            console.log('⚠️ Same element dropped — no action.');
            return;
        }

        let items = [...this.sections];

        const draggedIndex = items.findIndex(i => i.id === this.draggedItemId);
        const dropIndex = items.findIndex(i => i.id === droppedOnId);

        console.log(`   🔍 draggedIndex: ${draggedIndex}, dropIndex: ${dropIndex}`);

        // Reorder items
        const draggedItem = items.splice(draggedIndex, 1)[0];
        console.log('   📦 Item removed:', draggedItem);

        items.splice(dropIndex, 0, draggedItem);
        console.log('   📥 Item inserted at new position');

        console.log('   📌 Final Order:', items.map(i => i.id).join(' → '));

        this.sections = items;
    }
}