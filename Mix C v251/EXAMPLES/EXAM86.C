add_label()
{  struct label *new_label, *current_label, *previous_label;
   new_label = calloc(1, sizeof(struct label));
   if (new_label != NULL) {
      getlabel(new_label);
      new_label->next = NULL;
      if (first_label == NULL) first_label = new_label;
      else {
         current_label = first_label;
         while (current_label != NULL &&
            strcmp(new_label->name.last,
                   current_label->name.last) > 0) {
            previous_label = current_label;
            current_label = current_label->next; }
         if (current_label == first_label)
            first_label = new_label;
         else previous_label->next = new_label;
         new_label->next = current_label;
      }
   }
   else printf("<<< Out of Memory >>>\n");
}
